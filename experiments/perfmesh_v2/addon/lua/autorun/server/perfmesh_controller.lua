-- PerfMesh metrics stream (resolved merge)
if not SERVER then return end

_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }

-- === PerfMesh metrics stream for UI ===
util.AddNetworkString("perfmesh_metrics2")

timer.Create("PerfMesh_Metrics2", 0.5, 0, function()
  local pm = _G.PerfMesh or {}
  pm.ctrl  = pm.ctrl  or {}
  pm.state = pm.state or {}

  local used   = tonumber(pm.ctrl.used_ms_ema or 0) or 0
  local budget = (GetConVar("pm_tick_budget_ms") and GetConVar("pm_tick_budget_ms"):GetFloat()) or 4.0
  local hold   = (GetConVar("pm_pid_hold") and GetConVar("pm_pid_hold"):GetInt()) or 0
  local quiet  = (GetConVar("pm_quiet") and GetConVar("pm_quiet"):GetInt()) or 0
  local rag    = tonumber(pm.state.ragdolls or 0) or 0
  local npc    = tonumber(pm.state.npc_tracked or 0) or 0
  local preset = pm.state and (pm.state.preset_name or pm.state.preset or "balanced") or "balanced"

  net.Start("perfmesh_metrics2")
    net.WriteFloat(used)
    net.WriteFloat(budget)
    net.WriteUInt(hold, 1)
    net.WriteUInt(quiet, 1)
    net.WriteUInt(rag, 16)
    net.WriteUInt(npc, 16)
    net.WriteString(tostring(preset))
  net.Broadcast()
end)
