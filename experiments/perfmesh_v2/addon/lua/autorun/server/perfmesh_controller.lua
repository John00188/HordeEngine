local Controller = {}
PerfMesh.Controller = Controller

local log_len_cvar = CreateConVar("pm_log_len", "120", {FCVAR_ARCHIVE}, "PerfMesh log length", 30, 600)
local hold_cvar = CreateConVar("pm_pid_hold", "0", {FCVAR_ARCHIVE}, "Hold actuation")

Controller.log = {}
Controller.integral = 0
Controller.integral_clamp = 100

function Controller.add_sample(sample)
    table.insert(PerfMesh.Metrics.buffer, sample)
    table.insert(Controller.log, sample)
    while #Controller.log > log_len_cvar:GetInt() do
        table.remove(Controller.log, 1)
    end
end

function Controller.compute(err, dt)
    Controller.integral = math.Clamp(Controller.integral + err * dt, -Controller.integral_clamp, Controller.integral_clamp)
    local control = err + Controller.integral
    if hold_cvar:GetInt() == 1 then
        return control, true
    end
    -- actuation would occur here
    return control, false
end

function Controller.status()
    if hold_cvar:GetInt() == 1 then return "HOLD" end
    local dry = GetConVar("pm_dry_run") and GetConVar("pm_dry_run"):GetInt() == 1
    return dry and "DRY-RUN" or "ACTIVE"
end
