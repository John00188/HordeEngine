-- HordeEngine Client Module Loader
-- Loads the native C++ client module

print("[HordeEngine] Loading client module...")

local success = pcall(function() require("gmcl_hordeengine_win64") end)

if not success then
  print("[HordeEngine] WARNING: Failed to load gmcl_hordeengine_win64.dll")
  print("[HordeEngine] Client-side HordeEngine features will be unavailable.")
  return
end

print("[HordeEngine] Client module loaded successfully")

-- Client-side console command helper
concommand.Add("he_status_cl", function()
  print("[HordeEngine] Client status check")
end, nil, "Check HordeEngine client module status")

concommand.Add("he_bench_cl", function(cmd, args)
  local iterations = tonumber(args[1]) or 100000
  print("[HordeEngine] Running client benchmark with " .. iterations .. " iterations")
end, nil, "Run HordeEngine client benchmark: he_bench_cl <iterations>")
