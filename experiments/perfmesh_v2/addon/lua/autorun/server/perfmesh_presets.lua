-- PerfMesh v0.2.1 presets
if not SERVER then return end

_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }
local pm = _G.PerfMesh

-- Preset definitions
pm.Presets = {
  balanced  = { ragdolls=24, far_dist=2300, far_hz=3.0,  shadows=true },
  aggressive= { ragdolls=16, far_dist=2600, far_hz=2.0,  shadows=true },
  cinematic = { ragdolls=40, far_dist=1900, far_hz=4.0,  shadows=false },
}

-- Apply a preset via actuator layer
local function apply(p)
  local A = pm.Actuators or {}
  if A.setRagdollCap then A.setRagdollCap(p.ragdolls) end
  if A.setFarDistance then A.setFarDistance(p.far_dist) end
  if A.setFarHz then A.setFarHz(p.far_hz) end
  if A.setShadowPolicy then A.setShadowPolicy(p.shadows) end

  pm.state = pm.state or {}
  pm.state.preset = p

  -- mark config dirty so autosave will pick it up
  if pm.Config and pm.Config.mark_dirty then pm.Config.mark_dirty() end
end

-- Console command: perfmesh_preset <name>
concommand.Add("perfmesh_preset", function(_,_,args)
  local name = (args[1] or "balanced"):lower()
  local p = pm.Presets[name]
  if not p then
    print("[PerfMesh] unknown preset:", name)
    return
  end
  apply(p)
  print("[PerfMesh] preset ->", name)
end)
