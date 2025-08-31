-- PerfMesh v0.2.1 policies: ragdoll cap, npc pacing, shadows, adaptive tuning
if not SERVER then return end

_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }
local PM = _G.PerfMesh; if not PM then return end
local TAG = "[PM-Policy]"

-- ConVars
local cv_enable_policies = CreateConVar("pm_policies", "1", FCVAR_ARCHIVE, "Enable PerfMesh policies")
local cv_ragdoll_max     = CreateConVar("pm_ragdoll_max", "25", FCVAR_ARCHIVE, "Max ragdolls before trim")
local cv_no_shadows      = CreateConVar("pm_npc_no_shadows", "1", FCVAR_ARCHIVE, "Disable NPC shadows on spawn")
local cv_far_distance    = CreateConVar("pm_far_distance", "2200", FCVAR_ARCHIVE, "Distance for 'far' handling")
local cv_hz_near         = CreateConVar("pm_think_hz_near", "12", FCVAR_ARCHIVE, "Near update rate (Hz)")
local cv_hz_far          = CreateConVar("pm_think_hz_far", "3",  FCVAR_ARCHIVE, "Far update rate (Hz)")
local cv_cull_fov        = CreateConVar("pm_cull_out_of_fov", "1", FCVAR_ARCHIVE, "Treat far & out-of-FOV as low priority")
local cv_adaptive        = CreateConVar("pm_adaptive", "1", FCVAR_ARCHIVE, "Auto-tighten under load")
local cv_aggr_level      = CreateConVar("pm_aggressiveness", "1", FCVAR_ARCHIVE, "0=gentle,1=normal,2=aggressive,3=max")

-- State
local managed, ragdolls = {}, {}
local managed_idx = 1
local function is_npc(ent) return IsValid(ent) and (ent:IsNPC() or (ent.IsNextBot and ent:IsNextBot())) end
local function dbg(...) if GetConVar("pm_debug") and GetConVar("pm_debug"):GetBool() then print(TAG, ...) end end

-- Track ragdolls
hook.Add("OnEntityCreated","PM_RagdollTrack", function(ent)
    if not cv_enable_policies:GetBool() then return end
    if not IsValid(ent) then return end
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if ent:GetClass()=="prop_ragdoll" then
            table.insert(ragdolls, ent)
            local max = math.max(0, cv_ragdoll_max:GetInt())
            if max>0 and #ragdolls>max then
                local trim = #ragdolls - max
                for i=1,trim do local r = ragdolls[i]; if IsValid(r) then r:Remove() end end
                local new = {}
                for i=trim+1,#ragdolls do if IsValid(ragdolls[i]) then new[#new+1]=ragdolls[i] end end
                ragdolls = new
                dbg("Ragdolls trimmed", trim, "remain", #ragdolls)
            end
        end
    end)
end)

-- Track NPCs
hook.Add("OnEntityCreated","PM_NPCTrack", function(ent)
    if not cv_enable_policies:GetBool() then return end
    if not IsValid(ent) then return end
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if is_npc(ent) then
            managed[#managed+1] = ent
            if cv_no_shadows:GetBool() and ent.DrawShadow then pcall(function() ent:DrawShadow(false) end) end
        end
    end)
end)

-- Helper: nearest player info
local function nearest_player_info(ent)
    local best, oof = math.huge, true
    local pos = ent:GetPos()
    for _,ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local d = ply:GetPos():DistToSqr(pos)
            if d < best then
                best = d
                local dir = (pos - ply:EyePos()):GetNormalized()
                oof = (ply:EyeAngles():Forward():Dot(dir) <= 0)
            end
        end
    end
    return math.sqrt(best), oof
end

-- NPC scan job
PM.JobRegister("pm.policies.npc_scan", function()
    for i=#managed,1,-1 do if not IsValid(managed[i]) then table.remove(managed,i) end end
    PM.MetricSet("npc.tracked", #managed); PM.MetricSet("ragdolls.count", #ragdolls)
    if #managed==0 then return end

    local farDist = cv_far_distance:GetFloat()
    local near_dt = 1.0/math.max(1, cv_hz_near:GetInt())
    local far_dt  = 1.0/math.max(0.1, cv_hz_far:GetInt())
    local use_fov = cv_cull_fov:GetBool()

    local start = SysTime()
    local processed = 0
    while (SysTime()-start)*1000.0 < 0.75 do
        if managed_idx > #managed then managed_idx = 1 end
        local ent = managed[managed_idx]; managed_idx = managed_idx + 1
        if IsValid(ent) then
            local dist, oof = nearest_player_info(ent)
            local farish = dist > farDist
            local slow   = farish and (not use_fov or oof)
            if slow then
                pcall(function()
                    if ent.SetMaxLookDistance then ent:SetMaxLookDistance(math.max(500, farDist*0.6)) end
                    if ent.SetSaveValue then ent:SetSaveValue("m_bLagCompensate", false) end
                end)
                ent.__pm_next = (ent.__pm_next or 0); if ent.__pm_next < CurTime() then ent.__pm_next = CurTime() + far_dt end
            else
                ent.__pm_next = (ent.__pm_next or 0); if ent.__pm_next < CurTime() then ent.__pm_next = CurTime() + near_dt end
            end
        end
        processed = processed + 1
        if processed >= #managed then break end
    end
end, {hz=10, prio=10, slice_ms=0.9})

-- Adaptive policy job
PM.JobRegister("pm.policies.adaptive", function()
    if not cv_adaptive:GetBool() then return end
    local used = PM.metrics.ema["sched.used_ms"] or 0
    local budget = GetConVar("pm_tick_budget_ms"):GetFloat()
    local headroom = budget - used
    PM.MetricSet("sched.headroom_ms", headroom)

    local aggr = math.Clamp(cv_aggr_level:GetInt(),0,3)
    local step = (headroom < 0.2) and 1 or (headroom < 0.6 and 0 or -1)
    if step ~= 0 then
        local r = cv_ragdoll_max:GetInt()
        local delta = (step>0) and (-2-aggr) or (1+aggr)
        local nr = math.max(5, r + delta)
        if nr ~= r then RunConsoleCommand("pm_ragdoll_max", tostring(nr)) end

        local fd = cv_far_distance:GetFloat()
        local nfd = math.max(1200, fd + (step>0 and 200 or -150))
        if math.abs(nfd-fd) >= 1 then RunConsoleCommand("pm_far_distance", tostring(math.floor(nfd))) end

        local hf = cv_hz_far:GetFloat()
        local nhf = math.max(0.5, hf + (step>0 and -0.5 or 0.25))
        if math.abs(nhf-hf) >= 0.01 then RunConsoleCommand("pm_think_hz_far", tostring(nhf)) end
    end
end, {hz=2, prio=20, slice_ms=0.3})

-- Status command
concommand.Add("pm_policy_status", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    print(TAG, "policies=", cv_enable_policies:GetBool(),
        "ragdoll_max=", cv_ragdoll_max:GetInt(),
        "far=", cv_far_distance:GetFloat(),
        "hz_near=", cv_hz_near:GetInt(),
        "hz_far=",  cv_hz_far:GetFloat(),
        "no_shadows=", cv_no_shadows:GetBool(),
        "adaptive=", cv_adaptive:GetBool(), "aggr=", cv_aggr_level:GetInt())
end)

print(TAG, "active")
