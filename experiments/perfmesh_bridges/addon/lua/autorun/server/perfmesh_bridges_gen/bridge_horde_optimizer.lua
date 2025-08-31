-- Auto-generated PerfMesh bridge for: horde_optimizer
-- Non-destructive: listens/announces via PerfMesh only.
if not SERVER then return end
if not _G.PerfMesh then return end
local pm = _G.PerfMesh
local BRIDGE_ID = "bridge.horde_optimizer"

-- (Optional) quick presence hints for this addon (edit as you wish):
-- local present = ConVarExists("vj_npc_fade") or _G.VJBASE_VERSION
-- if not present then return end  -- uncomment if you want presence gating

-- Offer lightweight capability (others can query this):
pm.Offer("telemetry.horde_optimizer", BRIDGE_ID, {
    ping = function() return true end,
    info = function()
        return {
            addon="horde_optimizer",
            time=CurTime(),
            players=#player.GetAll()
        }
    end
}, 5)

-- Subscribe to global tuning broadcasts (cooperative):
pm.Subscribe("perf:tune", BRIDGE_ID, function(msg)
    if not msg then return end
    -- Example knobs you might forward to this addon (edit per real cvars):
    -- if msg.decals_max then RunConsoleCommand("r_decals", tostring(msg.decals_max)) end
end, 0)

-- Publish light telemetry periodically under the shared budget:
pm.JobRegister(BRIDGE_ID..".telemetry", function()
    local npcs = 0
    for _,e in ipairs(ents.GetAll()) do
        if IsValid(e) and (e:IsNPC() or (e.IsNextBot and e:IsNextBot())) then npcs = npcs + 1 end
    end
    pm.KVSet("telemetry.horde_optimizer.npcs", npcs, 3)
    pm.Publish("perf:telemetry", {source="horde_optimizer", npcs=npcs, t=CurTime()})
end, {hz=0.5, prio=1}) -- 0.5 Hz = every 2s; very light

print(string.format("[PerfMesh-Bridge] horde_optimizer stub active"))
