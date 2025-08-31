if not SERVER then return end
timer.Simple(5, function()
    if ConVarExists("ho_enabled") then
        print("[HO] selftest: ho_enabled=", GetConVar("ho_enabled"):GetBool())
    else
        print("[HO] selftest: ConVars missing?")
    end
end)
