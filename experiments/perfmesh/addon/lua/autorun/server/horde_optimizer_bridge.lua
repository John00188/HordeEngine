if not SERVER then return end
if not _G.PerfMesh then return end

-- If Horde Optimizer exposes nothing yet, we still help by offering a generic NPC scheduler service token
local pm = _G.PerfMesh
pm.Offer("npc_scheduler", "perfmesh_core", {
    -- Stub API other addons can call if HO does not provide its own
    classify = function(ent)
        if not IsValid(ent) then return "invalid" end
        local pos = ent:GetPos()
        local minDist = math.huge
        local oof = true
        for _,ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                local d = ply:GetPos():DistToSqr(pos)
                if d < minDist then
                    minDist = d
                    local dir = (pos - ply:EyePos()):GetNormalized()
                    oof = (ply:EyeAngles():Forward():Dot(dir) <= 0)
                end
            end
        end
        return (math.sqrt(minDist) > 2000 and oof) and "far" or "near"
    end
}, 10)
