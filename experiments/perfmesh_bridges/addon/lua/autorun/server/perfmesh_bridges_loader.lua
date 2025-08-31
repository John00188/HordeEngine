if not SERVER then return end
if not _G.PerfMesh then
    print("[PerfMesh-Bridges] PerfMesh not present; bridges idle")
    return
end
local root = "autorun/server/perfmesh_bridges_gen"
if not file.Exists(root, "LUA") then return end
local files = file.Find(root .. "/*.lua", "LUA")
for _, f in ipairs(files) do include(root .. "/" .. f) end
print(string.format("[PerfMesh-Bridges] Loaded %d bridge stub(s)", #files))
