-- HordeEngine Module Auto-Loader
-- Loads the appropriate client or server module

print("[HordeEngine] Initializing...")

if CLIENT then
  require("hordeengine/client")
else
  require("hordeengine/server")
end
