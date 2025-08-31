PerfMesh.Metrics = PerfMesh.Metrics or {}
local Metrics = PerfMesh.Metrics
Metrics.buffer = Metrics.buffer or {}

local function ts()
    return os.date("%Y%m%d_%H%M%S")
end

local function ensure_dir()
    local dir = PerfMesh.Config and PerfMesh.Config.data_dir or "perfmesh_v2"
    if not file.IsDir(dir, "DATA") then
        file.CreateDir(dir)
    end
    return dir
end

concommand.Add("perfmesh_export_metrics", function(ply)
    if IsValid(ply) then return end
    local dir = ensure_dir()
    local fname = string.format("%s/metrics_%s.csv", dir, ts())
    local out = {"t,used_ms_ema,headroom_ms,ragdolls,npc_tracked"}
    for _, m in ipairs(Metrics.buffer) do
        table.insert(out, string.format("%d,%.3f,%.3f,%d,%d", m.t or 0, m.used_ms_ema or 0, m.headroom_ms or 0, m.ragdolls or 0, m.npc_tracked or 0))
    end
    file.Write(fname, table.concat(out, "\n"))
    PerfMesh.log("[PerfMesh] exported metrics to " .. fname)
end)

concommand.Add("perfmesh_dump_state", function(ply)
    if IsValid(ply) then return end
    local dir = ensure_dir()
    local fname = string.format("%s/state_%s.json", dir, ts())
    local state = {
        cvars = {
            budget = GetConVar("pm_budget") and GetConVar("pm_budget"):GetFloat() or nil,
            far_dist = GetConVar("pm_far_dist") and GetConVar("pm_far_dist"):GetFloat() or nil,
            far_hz = GetConVar("pm_far_hz") and GetConVar("pm_far_hz"):GetFloat() or nil,
            ragdolls = PerfMesh.Actuator.targets and PerfMesh.Actuator.targets.ragdolls or nil,
            shadow_policy = PerfMesh.Actuator.targets and PerfMesh.Actuator.targets.shadows or nil,
            quiet = GetConVar("pm_quiet"):GetInt(),
            hold = GetConVar("pm_pid_hold") and GetConVar("pm_pid_hold"):GetInt() or 0,
        },
        controller_log = Metrics.buffer,
        job_ema = PerfMesh.JobRuntimes or {},
    }
    file.Write(fname, util.TableToJSON(state, true))
    PerfMesh.log("[PerfMesh] dumped state to " .. fname)
end)
