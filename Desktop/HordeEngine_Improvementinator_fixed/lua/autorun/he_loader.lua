-- he_loader.lua (shared)
-- Attempts to require('hordeengine') which resolves to gmcl_/gmsv_ automatically.

local ok, err = pcall(require, "hordeengine")
if not ok then
    MsgC(Color(255,80,80), "[HE] Failed to require 'hordeengine': ", tostring(err), "\n")
    return
end

-- Console helpers
if SERVER then
    concommand.Add("he_status", function(ply, cmd, args)
        local s = he.GetStatus()
        print(("[HE][SV] v=%s uptime=%.1fms jobs{%d/%d}"):format(s.version, s.uptime_ms, s.enqueued, s.executed))
    end)

    concommand.Add("he_bench", function(ply, cmd, args)
        local iters = tonumber(args[1] or "1000000") or 1000000
        local ms = he.Bench(iters)
        print(("[HE][SV] Bench(%d) -> %.2f ms"):format(iters, ms))
    end)
else
    concommand.Add("he_status_cl", function()
        local s = he.GetStatus()
        print(("[HE][CL] v=%s uptime=%.1fms jobs{%d/%d}"):format(s.version, s.uptime_ms, s.enqueued, s.executed))
    end)

    concommand.Add("he_bench_cl", function(_, _, args)
        local iters = tonumber(args[1] or "400000") or 400000
        local ms = he.Bench(iters)
        print(("[HE][CL] Bench(%d) -> %.2f ms"):format(iters, ms))
    end)
end
