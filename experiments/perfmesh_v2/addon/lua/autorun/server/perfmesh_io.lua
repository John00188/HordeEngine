if not SERVER then return end
_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }
local pm = _G.PerfMesh
pm.ctrl = pm.ctrl or { used_ms_ema = 0, history = {} }
pm.state = pm.state or {}

local function ts()
  return os.date("!%Y%m%d_%H%M%S")
end

concommand.Add("perfmesh_export_metrics", function()
  local dir = "perfmesh_v2"
  if not file.Exists(dir,"DATA") then file.CreateDir(dir) end
  local p = string.format("%s/metrics_%s.csv", dir, ts())
  local rows = {"t,used_ms_ema,headroom_ms,ragdolls,npc_tracked"}
  local budget = (GetConVar("pm_tick_budget_ms") and GetConVar("pm_tick_budget_ms"):GetFloat()) or 4.0
  for _,e in ipairs(pm.ctrl.history or {}) do
    local used = tonumber(e.used) or 0
    local head = math.max(0, budget - used)
    local rag  = tonumber((pm.state and pm.state.ragdolls) or 0) or 0
    local npc  = tonumber(pm.state.npc_tracked or 0) or 0
    table.insert(rows, string.format("%.3f,%.3f,%.3f,%d,%d", e.t, used, head, rag, npc))
  end
  file.Write(p, table.concat(rows,"\n"))
  print("[PerfMesh] wrote DATA/"..p)
end)

concommand.Add("perfmesh_dump_state", function()
  local dir = "perfmesh_v2"
  if not file.Exists(dir,"DATA") then file.CreateDir(dir) end
  local p = string.format("%s/state_%s.json", dir, ts())
  local snap = {
    version = pm.__v,
    cvars = {
      pm_quiet = GetConVar("pm_quiet") and GetConVar("pm_quiet"):GetInt() or 0,
      pm_pid_hold = GetConVar("pm_pid_hold") and GetConVar("pm_pid_hold"):GetInt() or 0,
      pm_log_len = GetConVar("pm_log_len") and GetConVar("pm_log_len"):GetInt() or 120,
      pm_tick_budget_ms = GetConVar("pm_tick_budget_ms") and GetConVar("pm_tick_budget_ms"):GetFloat() or 4.0,
    },
    state = pm.state or {},
    history = pm.ctrl and pm.ctrl.history or {},
  }
  file.Write(p, util.TableToJSON(snap,true))
  print("[PerfMesh] wrote DATA/"..p)
end)
