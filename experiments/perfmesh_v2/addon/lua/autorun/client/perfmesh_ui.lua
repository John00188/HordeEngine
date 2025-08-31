if not CLIENT then return end
_G.PerfMesh = _G.PerfMesh or { __v = _G.PerfMesh and _G.PerfMesh.__v or "0.2.1" }

concommand.Add("perfmesh_ui_toggle", function()
  hook.Run("PerfMeshUIToggle")
end)
