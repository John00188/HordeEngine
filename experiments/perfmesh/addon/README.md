# PerfMesh (Inter-Addon Mesh)
- Publish/Subscribe (`PerfMesh.Subscribe/Publish`)
- Cooperative jobs under a global time budget (`PerfMesh.JobRegister`)
- Capability registry (`PerfMesh.Offer/GetService`)
- Priority claims (`PerfMesh.Claim/Release/Heartbeat`)
- KV store (`PerfMesh.KVSet/KVGet`)

Console:
- perfmesh_status
ConVars:
- pm_enabled (1)
- pm_debug (0)
- pm_tick_budget_ms (2.0)
