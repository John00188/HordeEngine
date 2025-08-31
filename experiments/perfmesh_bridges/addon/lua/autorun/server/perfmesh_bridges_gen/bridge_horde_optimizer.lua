-- Auto-generated PerfMesh bridge for: horde_optimizer
if not SERVER then return end
if not _G.PerfMesh then return end
local pm = _G.PerfMesh
local BRIDGE_ID = "bridge.horde_optimizer"
pm.Offer("telemetry.horde_optimizer", BRIDGE_ID, {
    ping = function() return true end,
    info = function() return { addon="horde_optimizer", time=CurTime(), players=#player.GetAll() } end
}, 1)
pm.Subscribe("perf:tune", BRIDGE_ID, function(msg) end, 0)
pm.JobRegister(BRIDGE_ID..".telemetry", function()
    local npcs = 0
    for _,e in ipairs(ents.GetAll()) do
        if IsValid(e) and (e:IsNPC() or (e.IsNextBot and e:IsNextBot())) then npcs = npcs + 1 end
    end
    pm.KVSet("telemetry.horde_optimizer.npcs", npcs, 3)
    pm.Publish("perf:telemetry", {source="horde_optimizer", npcs=npcs, t=CurTime()})
end, {hz=0.5, prio=1})
print(string.format("[PerfMesh-Bridge] horde_optimizer stub active"))
