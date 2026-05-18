-- HordeEngine Server Module Loader
-- Loads the native C++ server module and sets up console commands

print("[HordeEngine] Loading server module...")

local success = pcall(function() require("gmsv_hordeengine_win64") end)

if not success then
  print("[HordeEngine] ERROR: Failed to load gmsv_hordeengine_win64.dll")
  print("[HordeEngine] Make sure the binary is present in garrysmod/lua/bin/")
  print("[HordeEngine] The addon requires a compiled native module.")
  return
end

print("[HordeEngine] Server module loaded successfully")
print("[HordeEngine] Available commands: he_status, he_bench")

-- Server-side console command helper
concommand.Add("he_status", function(ply, cmd, args)
  if ply:IsValid() and not ply:IsAdmin() then
    ply:ChatPrint("You do not have permission to use this command.")
    return
  end
  print("[HordeEngine] Status check")
end, nil, "Check HordeEngine server module status")

concommand.Add("he_bench", function(ply, cmd, args)
  if ply:IsValid() and not ply:IsAdmin() then
    ply:ChatPrint("You do not have permission to use this command.")
    return
  end
  local iterations = tonumber(args[1]) or 100000
  print("[HordeEngine] Running benchmark with " .. iterations .. " iterations")
end, nil, "Run HordeEngine benchmark: he_bench <iterations>")
