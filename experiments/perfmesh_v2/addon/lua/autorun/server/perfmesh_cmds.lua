if not SERVER then return end
_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }
local pm = _G.PerfMesh

local function getint(name, def)
  local c = GetConVar(name)
  if not c and def ~= nil then
    if name == "pm_quiet" then CreateConVar("pm_quiet","0",FCVAR_ARCHIVE,"PerfMesh quiet mode") c = GetConVar("pm_quiet") end
    if name == "pm_pid_hold" then CreateConVar("pm_pid_hold","0",FCVAR_ARCHIVE,"PerfMesh hold outputs") c = GetConVar("pm_pid_hold") end
  end
  return c and c:GetInt() or def
end
local function setint(name, v) local c = GetConVar(name); if c then c:SetInt(v) end end
local function getfloat(name, def) local c = GetConVar(name); return c and c:GetFloat() or def end

concommand.Add("perfmesh_quiet", function(_,_,args)
  if not args[1] then print("pm_quiet =", getint("pm_quiet",0)) return end
  local v = tonumber(args[1]) and (tonumber(args[1])>0 and 1 or 0) or 0
  setint("pm_quiet", v); print("[PerfMesh] quiet ->", getint("pm_quiet",0))
end)

concommand.Add("perfmesh_hold", function(_,_,args)
  if not args[1] then print("pm_pid_hold =", getint("pm_pid_hold",0)) return end
  local v = tonumber(args[1]) and (tonumber(args[1])>0 and 1 or 0) or 0
  setint("pm_pid_hold", v); print("[PerfMesh] hold ->", getint("pm_pid_hold",0))
end)

concommand.Add("perfmesh_info", function()
  pm.ctrl  = pm.ctrl  or {}
  pm.state = pm.state or {}
  local used   = tonumber(pm.ctrl.used_ms_ema or 0) or 0
  local budget = getfloat("pm_tick_budget_ms", 4.0)
  local head   = math.max(0, budget - used)
  local quiet  = getint("pm_quiet",0)
  local hold   = getint("pm_pid_hold",0)
  local preset = pm.state.preset_name or pm.state.preset or "balanced"
  print(string.format("[PerfMesh] v%s quiet=%d hold=%d preset=%s used=%.2fms head=%.2fms budget=%.2fms",
    tostring(pm.__v or "?"), quiet, hold, tostring(preset), used, head, budget))
end)

concommand.Add("pmp", function()
  pm.state = pm.state or {}
  local order = { "balanced","aggressive","cinematic" }
  local cur = tostring(pm.state.preset_name or pm.state.preset or "balanced")
  local idx = 1; for i,n in ipairs(order) do if n==cur then idx=i break end end
  local nextn = order[(idx % #order) + 1]
  RunConsoleCommand("perfmesh_preset", nextn)
  print("[PerfMesh] preset ->", nextn)
end)

concommand.Add("perfmesh_demo_showcase", function()
  RunConsoleCommand("pm_quiet","0")
  RunConsoleCommand("pm_pid_hold","0")
  RunConsoleCommand("perfmesh_preset","balanced")
  timer.Simple(1.0, function() RunConsoleCommand("pm_pid_hold","1") end)
  timer.Simple(2.0, function() RunConsoleCommand("pm_pid_hold","0") end)
  timer.Simple(3.0, function() RunConsoleCommand("perfmesh_preset","aggressive") end)
  timer.Simple(4.0, function() RunConsoleCommand("perfmesh_preset","cinematic") end)
  timer.Simple(5.0, function() RunConsoleCommand("perfmesh_export_metrics") end)
  print("[PerfMesh] demo queued")
end)

print("[PerfMesh Commands] installed")
