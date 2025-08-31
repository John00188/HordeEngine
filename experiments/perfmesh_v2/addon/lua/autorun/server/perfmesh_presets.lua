local presets = {
    balanced = { ragdolls = 24, far_dist = 2300, far_hz = 3.0, shadows = true },
    aggressive = { ragdolls = 16, far_dist = 2600, far_hz = 2.0, shadows = true },
    cinematic = { ragdolls = 40, far_dist = 1900, far_hz = 4.0, shadows = false },
}

PerfMesh.Actuator.targets = PerfMesh.Actuator.targets or {}

function PerfMesh.Actuator.setRagdollCap(v)
    PerfMesh.Actuator.targets.ragdolls = v
end

function PerfMesh.Actuator.setFarDist(v)
    PerfMesh.Actuator.targets.far_dist = v
end

function PerfMesh.Actuator.setFarHz(v)
    PerfMesh.Actuator.targets.far_hz = v
end

function PerfMesh.Actuator.setShadows(on)
    PerfMesh.Actuator.targets.shadows = on and 1 or 0
end

local function apply(preset)
    local cfg = presets[preset]
    if not cfg then return end
    PerfMesh.Actuator.setRagdollCap(cfg.ragdolls)
    PerfMesh.Actuator.setFarDist(cfg.far_dist)
    PerfMesh.Actuator.setFarHz(cfg.far_hz)
    PerfMesh.Actuator.setShadows(cfg.shadows)
    PerfMesh.log("[PerfMesh] applied preset " .. preset)
end

concommand.Add("perfmesh_preset", function(ply, cmd, args)
    if IsValid(ply) then return end
    apply(args[1])
end)
