if not SERVER then return end
_G.PerfMesh = _G.PerfMesh or {}
_G.PerfMesh.__v = "0.2.1"

if not ConVarExists("pm_quiet") then
  CreateConVar("pm_quiet","0",FCVAR_ARCHIVE,"PerfMesh quiet mode (0=verbose,1=quiet)")
end

print("[PerfMesh] loaded v0.2.1")
