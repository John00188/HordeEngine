# PerfMesh v2 Design

This document describes the PerfMesh v2 controller and runtime.

## Hold mode
The `pm_pid_hold` cvar allows the controller to compute error and control values without applying them to the actuators. Metrics and logs continue to update while actuation is frozen.

## Export formats
`perfmesh_export_metrics` writes CSV metrics with headers `t,used_ms_ema,headroom_ms,ragdolls,npc_tracked`.
`perfmesh_dump_state` writes a JSON snapshot including key cvars, the controller ring buffer and per-job EMA runtimes.
