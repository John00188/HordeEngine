-- PerfMesh (server) — a tiny inter-addon mesh for Garry's Mod
-- Drop-in path (recommended folder name): garrysmod/addons/perfmesh/
-- Features:
--   - Publish/Subscribe channels with priorities
--   - Shared time-budget scheduler for cooperative jobs
--   - Capability registry and resource claims (conflict avoidance)
--   - Minimal KV store with TTL
--   - Status commands

if not SERVER then return end
if _G.PerfMesh and _G.PerfMesh.__v then return end  -- already loaded

local PM = {}
PM.__v = "0.1.0"
PM.__tag = "[PerfMesh]"
PM.debug = false

-- ConVars
local cv_enabled     = CreateConVar("pm_enabled", "1", FCVAR_ARCHIVE, "Enable PerfMesh hub")
local cv_debug       = CreateConVar("pm_debug",   "0", FCVAR_ARCHIVE, "Debug logs")
local cv_tick_budget = CreateConVar("pm_tick_budget_ms", "2.0", FCVAR_ARCHIVE, "Global per-frame budget for PerfMesh (ms)")

local function dbg(...) if cv_debug:GetBool() then print(PM.__tag, ...) end end

-- =============== Pub/Sub =================
-- subs[channel] = { {prio=<n>, id=<string>, fn=<function>}, ... }
PM.subs = {}
function PM.Subscribe(channel, id, fn, prio)
    if not cv_enabled:GetBool() then return end
    assert(type(channel)=="string" and channel~="", "channel required")
    assert(type(id)=="string" and id~="", "id required")
    assert(type(fn)=="function", "fn required")
    prio = tonumber(prio or 0) or 0
    PM.subs[channel] = PM.subs[channel] or {}
    table.insert(PM.subs[channel], {id=id,fn=fn,prio=prio})
    table.sort(PM.subs[channel], function(a,b) return a.prio>b.prio end)
    dbg("subscribed", channel, "id=", id, "prio=", prio)
end

function PM.Unsubscribe(channel, id)
    local t = PM.subs[channel]; if not t then return end
    for i=#t,1,-1 do if t[i].id==id then table.remove(t,i) end end
end

function PM.Publish(channel, payload)
    if not cv_enabled:GetBool() then return end
    local t = PM.subs[channel]; if not t then return end
    for _,s in ipairs(t) do
        local ok,err = pcall(s.fn, payload)
        if not ok then dbg("Publish error on", channel, s.id, err) end
    end
end

-- =============== Jobs / Scheduler =================
-- Cooperative jobs that run under a global per-frame time budget
-- PM.JobRegister(id, fn, {hz=10, prio=0})
PM.jobs = {}
function PM.JobRegister(id, fn, opts)
    assert(type(id)=="string" and id~="", "job id")
    assert(type(fn)=="function", "job fn")
    opts = opts or {}
    local hz   = math.max(1, tonumber(opts.hz or 10) or 10)
    local prio = tonumber(opts.prio or 0) or 0
    PM.jobs[id] = {fn=fn,hz=hz,prio=prio,next_t=CurTime()}
    dbg("job registered", id, "hz=",hz,"prio=",prio)
end

function PM.JobUnregister(id) PM.jobs[id]=nil end

hook.Add("Think","PerfMesh_Scheduler", function()
    if not cv_enabled:GetBool() then return end
    local budget_ms = math.max(0.25, cv_tick_budget:GetFloat())
    local t0 = SysTime()
    local now = CurTime()

    -- sort by priority (stable)
    local list = {}
    for id,j in pairs(PM.jobs) do list[#list+1]={id=id,j=j} end
    table.sort(list, function(a,b) return a.j.prio > b.j.prio end)

    for _,item in ipairs(list) do
        if (SysTime() - t0)*1000.0 >= budget_ms then break end
        local j = item.j
        if now >= (j.next_t or 0) then
            j.next_t = now + 1.0 / j.hz
            local ok,err = pcall(j.fn)
            if not ok then dbg("job error", item.id, err) end
        end
    end
end)

-- =============== Capability Registry =================
-- Services[name] = { provider_id, prio, api=<table> }
PM.services = {}
function PM.Offer(name, provider_id, api, prio)
    assert(type(name)=="string" and name~="", "service name")
    assert(type(provider_id)=="string" and provider_id~="", "provider id")
    prio = tonumber(prio or 0) or 0
    local cur = PM.services[name]
    if not cur or prio > cur.prio then
        PM.services[name] = {provider=provider_id, api=api, prio=prio, time=CurTime()}
        PM.Publish("perfmesh:service_changed", {name=name,provider=provider_id,prio=prio})
        dbg("service chosen", name, "->", provider_id, "prio", prio)
    else
        dbg("service offer ignored (lower prio)", name, "by", provider_id)
    end
end
function PM.GetService(name) local s=PM.services[name]; return s and s.api or nil end

-- =============== Resource Claims (mutex with priority) ================
-- Claims[resource]= { holder=id, prio, ttl=CurTime()+x }
PM.claims = {}
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
function PM.Heartbeat(resource, id, ttl)
    local c = PM.claims[resource]; if not c or c.holder~=id then return false end
    c.ttl = CurTime() + (ttl or 5); return true
end
function PM.Release(resource, id)
    local c = PM.claims[resource]; if c and c.holder==id then
        PM.claims[resource]=nil
        PM.Publish("perfmesh:claim_changed", {resource=resource,holder=nil})
        return true
    end
    return false
end

-- =============== Tiny KV (with TTL) ===============
PM.kv = {}
function PM.KVSet(key, val, ttl)
    PM.kv[key] = {v=val, exp = ttl and (CurTime()+ttl) or nil}
end
function PM.KVGet(key)
    local e = PM.kv[key]
    if not e then return nil end
    if e.exp and e.exp < CurTime() then PM.kv[key]=nil; return nil end
    return e.v
end

-- =============== Status & Debug ====================
concommand.Add("perfmesh_status", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    print(PM.__tag, "v"..PM.__v, "enabled=", cv_enabled:GetBool(), "jobs=", table.Count(PM.jobs))
    print(" Services:", table.Count(PM.services))
    for name,s in pairs(PM.services) do print("  -",name,"by",s.provider,"prio",s.prio) end
    print(" Claims:", table.Count(PM.claims))
    for r,c in pairs(PM.claims) do print("  -",r,"->",c.holder,"prio",c.prio) end
end)

-- Announce ready for listeners
timer.Simple(0, function() PM.Publish("perfmesh:ready", {version=PM.__v}) end)

_G.PerfMesh = PM
print(PM.__tag, "loaded v"..PM.__v)
