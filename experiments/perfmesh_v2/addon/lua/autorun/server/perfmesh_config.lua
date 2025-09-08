-- PerfMesh config (resolved merge)
if not SERVER then return end

_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }
local pm = _G.PerfMesh
pm.Config = pm.Config or {}
local C = pm.Config

C.path_dir  = "perfmesh_v2"
C.path_file = C.path_dir .. "/config.json"
C.dirty = false
C.autosave_interval_sec = C.autosave_interval_sec or 120

local function ensureDir()
  if not file.Exists(C.path_dir, "DATA") then file.CreateDir(C.path_dir) end
end

function C.load()
  ensureDir()
  if file.Exists(C.path_file, "DATA") then
    local ok, t = pcall(util.JSONToTable, file.Read(C.path_file, "DATA") or "{}")
    if ok and istable(t) then
      pm.state = t
      return t
    end
  end
  pm.state = pm.state or { preset = "balanced" }
  C.save()
  return pm.state
end

function C.save()
  ensureDir()
  local ok, js = pcall(util.TableToJSON, pm.state or {}, true)
  if ok and js then
    file.Write(C.path_file, js)
    C.dirty = false
  end
end

function C.mark_dirty()
  C.dirty = true
end
concommand.Add("perfmesh_config_mark_dirty", function()
  C.mark_dirty()
end)

-- autosave timer (independent of scheduler)
timer.Create("PerfMesh_Autosave", C.autosave_interval_sec, 0, function()
  if C.dirty then C.save() end
end)

-- load initial state if missing
if not pm.state then C.load() end

-- startup message (unless quiet)
if GetConVar("pm_quiet") and GetConVar("pm_quiet"):GetInt() == 0 then
  print("[PerfMesh] config online -> data/" .. C.path_file)
end

