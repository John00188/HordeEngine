-- Horde Optimizer (server-side, drop-in)
-- Folder name suggestion: garrysmod/addons/horde_optimizer/
-- Safe defaults: throttled NPC processing, ragdoll cap, no NPC shadows.

if not SERVER then return end

local addon_tag = "[HO]"
local cv_enabled        = CreateConVar("ho_enabled", "1", FCVAR_ARCHIVE, "Enable Horde Optimizer")
local cv_max_ragdolls   = CreateConVar("ho_ragdoll_max", "30", FCVAR_ARCHIVE, "Max ragdolls; older ones get removed")
local cv_tick_budget_ms = CreateConVar("ho_tick_budget_ms", "2.5", FCVAR_ARCHIVE, "Per-frame time budget for optimizer (ms)")
local cv_far_dist       = CreateConVar("ho_far_distance", "2500", FCVAR_ARCHIVE, "NPCs beyond this are treated as 'far'")
local cv_near_hz        = CreateConVar("ho_think_hz_near", "10", FCVAR_ARCHIVE, "Near update rate (Hz)")
local cv_far_hz         = CreateConVar("ho_think_hz_far",  "2",  FCVAR_ARCHIVE, "Far update rate (Hz)")
local cv_cull_fov       = CreateConVar("ho_cull_out_of_fov", "1", FCVAR_ARCHIVE, "Treat far & out-of-FOV NPCs as low-priority")
local cv_no_shadows     = CreateConVar("ho_npc_no_shadows", "1", FCVAR_ARCHIVE, "Disable shadows on new NPCs")
local cv_debug          = CreateConVar("ho_debug", "0", FCVAR_ARCHIVE, "Debug spam")

local managed = {}
local managed_idx = 1
local ragdolls = {}

local function dbg(...) if cv_debug:GetBool() then print(addon_tag, ...) end end
local function is_valid_npc(ent) return IsValid(ent) and (ent:IsNPC() or (ent.IsNextBot and ent:IsNextBot())) end

hook.Add("OnEntityCreated", "HO_RagdollTrack", function(ent)
    if not cv_enabled:GetBool() then return end
    if not IsValid(ent) then return end
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if ent:GetClass() == "prop_ragdoll" then
            table.insert(ragdolls, ent)
            local max = math.max(0, cv_max_ragdolls:GetInt())
            if max > 0 and #ragdolls > max then
                local removed = 0
                for i = 1, #ragdolls - max do
                    local r = ragdolls[i]
                    if IsValid(r) then r:Remove() removed = removed + 1 end
                end
                local new = {}
                for i = math.max(1, #ragdolls - max + 1), #ragdolls do
                    if IsValid(ragdolls[i]) then table.insert(new, ragdolls[i]) end
                end
                ragdolls = new
                dbg("Ragdolls trimmed:", removed, "remaining:", #ragdolls)
            end
        end
    end)
end)

hook.Add("OnEntityCreated", "HO_NPCTrack", function(ent)
    if not cv_enabled:GetBool() then return end
    if not IsValid(ent) then return end
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if is_valid_npc(ent) then
            table.insert(managed, ent)
            if cv_no_shadows:GetBool() and ent.DrawShadow then pcall(function() ent:DrawShadow(false) end) end
        end
    end)
end)

local function nearest_player_info(ent)
    local bestDist, out_of_fov = math.huge, true
    local pos = ent:GetPos()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local d = ply:GetPos():DistToSqr(pos)
            if d < bestDist then
                bestDist = d
                local dir = (pos - ply:EyePos()):GetNormalized()
                local dot = ply:EyeAngles():Forward():Dot(dir)
                out_of_fov = dot <= 0
            end
        end
    end
    return math.sqrt(bestDist), out_of_fov
end

hook.Add("Think", "HO_Tick", function()
    if not cv_enabled:GetBool() then return end
    if #managed == 0 then return end

    for i = #managed, 1, -1 do if not IsValid(managed[i]) then table.remove(managed, i) end end
    if #managed == 0 then return end

    local budget_ms = math.max(0.25, cv_tick_budget_ms:GetFloat())
    local t0 = SysTime()
    local farDist = cv_far_dist:GetFloat()
    local near_dt = 1.0 / math.max(1, cv_near_hz:GetInt())
    local far_dt  = 1.0 / math.max(1, cv_far_hz:GetInt())
    local use_fov = cv_cull_fov:GetBool()

    local processed = 0
    while (SysTime() - t0) * 1000.0 < budget_ms do
        if managed_idx > #managed then managed_idx = 1 end
        local ent = managed[managed_idx]
        managed_idx = managed_idx + 1

        if IsValid(ent) then
            local dist, oof = nearest_player_info(ent)
            local farish = dist > farDist
            local slow   = farish and (not use_fov or oof)

            if slow then
                pcall(function()
                    if ent.SetMaxLookDistance then ent:SetMaxLookDistance(math.max(500, farDist * 0.5)) end
                    if ent.SetSaveValue then ent:SetSaveValue("m_bLagCompensate", false) end
                end)
                ent.__ho_next = (ent.__ho_next or 0)
                if ent.__ho_next < CurTime() then ent.__ho_next = CurTime() + far_dt end
            else
                ent.__ho_next = (ent.__ho_next or 0)
                if ent.__ho_next < CurTime() then ent.__ho_next = CurTime() + near_dt end
            end
        end

        processed = processed + 1
        if processed >= #managed then break end
    end
end)

concommand.Add("ho_status", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    print(addon_tag, "enabled=", cv_enabled:GetBool(), "tracked_npcs=", #managed, "ragdolls=", #ragdolls)
end)

concommand.Add("ho_toggle", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    local v = cv_enabled:GetBool() and 0 or 1
    RunConsoleCommand("ho_enabled", tostring(v))
    print(addon_tag, "enabled set to", v)
end)

print(addon_tag, "Horde Optimizer loaded.")
