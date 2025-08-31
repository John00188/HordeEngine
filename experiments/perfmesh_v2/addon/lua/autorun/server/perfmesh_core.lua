_G.PerfMesh = _G.PerfMesh or {}

local pm_quiet = CreateConVar("pm_quiet", "0", {FCVAR_ARCHIVE}, "Suppress non-critical PerfMesh logs")

PerfMesh.__v = "0.2.1"

local function log(msg)
    if pm_quiet:GetInt() == 0 then
        print(msg)
    end
end

PerfMesh.log = log

log("[PerfMesh] loaded v" .. PerfMesh.__v)

function PerfMesh.safe_call(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        print("[PerfMesh] error: " .. tostring(err))
    end
    return ok, err
end

PerfMesh.Actuator = PerfMesh.Actuator or {}
