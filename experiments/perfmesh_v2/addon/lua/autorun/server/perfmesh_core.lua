-- PerfMesh v0.2.0 (server) — control-plane scheduler + bus + metrics
if not SERVER then return end
if _G.PerfMesh and _G.PerfMesh.__v == "0.2.0" then return end

local PM = _G.PerfMesh or {}
PM.__v   = "0.2.1"
PM.__tag = "[PerfMesh]"
PM.debug = false

local cv_enabled   = CreateConVar("pm_enabled", "1", FCVAR_ARCHIVE, "Enable PerfMesh")
local cv_debug     = CreateConVar("pm_debug", "0", FCVAR_ARCHIVE, "Debug logs")
local cv_budget_ms = CreateConVar("pm_tick_budget_ms", "2.5", FCVAR_ARCHIVE, "Global frame budget (ms)")
local cv_trace     = CreateConVar("pm_trace", "0", FCVAR_ARCHIVE, "Trace scheduling decisions")

local function dbg(...) if cv_debug:GetBool() then print(PM.__tag, ...) end end

-- Pub/Sub
PM.subs = PM.subs or {}
function PM.Subscribe(ch, id, fn, prio)
    if not cv_enabled:GetBool() then return end
    assert(type(ch)=="string" and ch~="", "channel")
    assert(type(id)=="string" and id~="", "id")
    assert(type(fn)=="function", "fn")
    prio = tonumber(prio or 0) or 0
    local t = PM.subs[ch] or {}
    t[#t+1] = {id=id, fn=fn, prio=prio}
    table.sort(t, function(a,b) return a.prio>b.prio end)
    PM.subs[ch] = t
    dbg("Subscribe", ch, id, "prio", prio)
end
function PM.Unsubscribe(ch, id)
    local t = PM.subs[ch]; if not t then return end
    for i=#t,1,-1 do if t[i].id==id then table.remove(t,i) end end
end
function PM.Publish(ch, payload)
    if not cv_enabled:GetBool() then return end
    local t = PM.subs[ch]; if not t then return end
    for _,s in ipairs(t) do local ok,err=pcall(s.fn, payload); if not ok then dbg("Publish err", ch, s.id, err) end end
end

-- Services
PM.services = PM.services or {}
function PM.Offer(name, provider_id, api, prio)
    assert(type(name)=="string" and name~="", "service name")
    assert(type(provider_id)=="string" and provider_id~="", "provider id")
    prio = tonumber(prio or 0) or 0
    local cur = PM.services[name]
    if not cur or prio > cur.prio then
        PM.services[name] = {provider=provider_id, api=api, prio=prio, time=CurTime()}
        PM.Publish("perfmesh:service_changed", {name=name,provider=provider_id,prio=prio})
        dbg("Service chosen", name, "->", provider_id, "prio", prio)
    end
end
function PM.GetService(name) local s=PM.services[name]; return s and s.api or nil end

-- Claims
PM.claims = PM.claims or {}
function PM.Claim(resource, id, prio, ttl)
    assert(type(resource)=="string" and resource~="", "resource")
    assert(type(id)=="string" and id~="", "id")
    prio = tonumber(prio or 0) or 0
    ttl  = tonumber(ttl or 5) or 5
    local c = PM.claims[resource]
    if not c or prio >= c.prio or (c.ttl and c.ttl < CurTime()) then
        PM.claims[resource] = {holder=id, prio=prio, ttl=CurTime()+ttl}
        PM.Publish("perfmesh:claim_changed", {resource=resource,holder=id,prio=prio})
        return true
    end
    return false
end
function PM.Heartbeat(resource, id, ttl) local c=PM.claims[resource]; if c and c.holder==id then c.ttl=CurTime()+(ttl or 5) return true end end
function PM.Release(resource, id) local c=PM.claims[resource]; if c and c.holder==id then PM.claims[resource]=nil; PM.Publish("perfmesh:claim_changed",{resource=resource,holder=nil}) return true end end

-- Metrics
PM.metrics = PM.metrics or {counters={}, gauges={}, ema={}}
local function ema(old, new, a) if old==nil then return new end return old*(1-a)+new*a end
function PM.MetricInc(k, d) PM.metrics.counters[k]=(PM.metrics.counters[k] or 0)+(d or 1) end
function PM.MetricSet(k, v) PM.metrics.gauges[k]=v end
function PM.MetricEma(k, v, a) PM.metrics.ema[k]=ema(PM.metrics.ema[k], v, a or 0.2) end

-- Scheduler v2
PM.jobs = PM.jobs or {}
function PM.JobRegister(id, fn, opts)
    assert(type(id)=="string" and id~="", "job id")
    assert(type(fn)=="function", "job fn")
    opts = opts or {}
    local hz   = math.max(0.1, tonumber(opts.hz or 10) or 10)
    local prio = tonumber(opts.prio or 0) or 0
    local slice_ms = tonumber(opts.slice_ms or 0.2) or 0.2
    PM.jobs[id] = {fn=fn,hz=hz,prio=prio,next_t=CurTime(),slice_ms=slice_ms,avg_ms=0}
end
function PM.JobUnregister(id) PM.jobs[id]=nil end

hook.Add("Think","PerfMesh_Scheduler2", function()
    if not cv_enabled:GetBool() then return end
    local budget_ms = math.max(0.25, cv_budget_ms:GetFloat())
    local t0 = SysTime()
    local now = CurTime()

    local list = {}
    for id,j in pairs(PM.jobs) do list[#list+1]={id=id,j=j} end
    table.sort(list, function(a,b) return a.j.prio>b.j.prio end)

    local used_ms = 0
    for _,item in ipairs(list) do
        if (SysTime()-t0)*1000.0 >= budget_ms then break end
        local j = item.j
        if now >= (j.next_t or 0) then
            j.next_t = now + 1.0 / j.hz
            local jt0 = SysTime()
            local ok,err = pcall(j.fn)
            local dur_ms = (SysTime()-jt0)*1000.0
            j.avg_ms = (j.avg_ms*0.8) + (dur_ms*0.2)
            used_ms = (SysTime()-t0)*1000.0
            PM.MetricEma("sched.job_ms."..item.id, dur_ms, 0.2)
            if cv_trace:GetBool() then print(PM.__tag, "job", item.id, string.format("%.3fms", dur_ms)) end
            if dur_ms > j.slice_ms then j.hz = math.max(0.1, j.hz*0.9) end
        end
    end
    PM.MetricEma("sched.used_ms", used_ms, 0.2)
end)

-- Commands
concommand.Add("perfmesh_status", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    print(PM.__tag, "v"..PM.__v, "enabled=", cv_enabled:GetBool(), "jobs=", table.Count(PM.jobs))
    print(" Services:", table.Count(PM.services or {}))
    for k,s in pairs(PM.services or {}) do print("  -",k,"by",s.provider,"prio",s.prio) end
    print(" Claims:", table.Count(PM.claims or {}))
    for r,c in pairs(PM.claims or {}) do print("  -",r,"->",c.holder,"prio",c.prio) end
    print(string.format(" Budget=%.2fms Used(ema)=%.2fms", cv_budget_ms:GetFloat(), PM.metrics.ema["sched.used_ms"] or 0))
end)
concommand.Add("perfmesh_metrics", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    print(PM.__tag, "metrics:")
    for k,v in pairs(PM.metrics.gauges) do print(" gauge",k,v) end
    for k,v in pairs(PM.metrics.counters) do print(" counter",k,v) end
    for k,v in pairs(PM.metrics.ema) do print(string.format(" ema %s = %.3f",k,v)) end
end)

_G.PerfMesh = PM
timer.Simple(0, function() PM.Publish("perfmesh:ready", {version=PM.__v}) end)
print(PM.__tag, "loaded v"..PM.__v)

