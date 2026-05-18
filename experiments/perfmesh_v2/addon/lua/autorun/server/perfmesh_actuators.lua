-- PerfMesh server core (resolved merge)
if not SERVER then return end

_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }
local pm = _G.PerfMesh

pm.Actuators = pm.Actuators or {}
local A = pm.Actuators

-- quiet-aware print
local function qprint(...)
  local q = GetConVar("pm_quiet")
  if q and q:GetInt() == 1 then return end
  print(...)
end

-- clamp utility
local function clamp(x,a,b) return math.max(a, math.min(b, x)) end

-- state table
pm.state = pm.state or {}

-- actuators
function A.setRagdollCap(n)
  pm.state.ragdolls = clamp(tonumber(n) or 24, 5, 60)
  qprint("[PerfMesh] ragdoll cap ->", pm.state.ragdolls)
end

function A.setFarDistance(m)
  pm.state.far_dist = clamp(tonumber(m) or 2300, 800, 6000)
  qprint("[PerfMesh] far distance ->", pm.state.far_dist)
end

function A.setFarHz(hz)
  pm.state.far_hz = clamp(tonumber(hz) or 3.0, 0.5, 12.0)
  qprint("[PerfMesh] far Hz ->", pm.state.far_hz)
end

function A.setShadowPolicy(on)
  pm.state.shadows = (on and true) or false
  qprint("[PerfMesh] npc shadows ->", pm.state.shadows and "on" or "off")
end

