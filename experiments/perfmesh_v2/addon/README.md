# PerfMesh v2

## Quiet mode
Set `pm_quiet 1` to suppress non-essential log output. Error logs always print.

## Autosave
Configuration is stored under `garrysmod/data/perfmesh_v2/`. When `PerfMesh.Config.mark_dirty()` is called the config is saved automatically every `autosave_interval_sec` (default 120 seconds).

## Presets
`perfmesh_preset balanced|aggressive|cinematic` applies tuned actuator targets:

- **balanced**: ragdolls=24, far_dist=2300, far_hz=3.0, shadows=on
- **aggressive**: ragdolls=16, far_dist=2600, far_hz=2.0, shadows=on
- **cinematic**: ragdolls=40, far_dist=1900, far_hz=4.0, shadows=off

## Export and Dump
`perfmesh_export_metrics` writes a CSV with headers `t,used_ms_ema,headroom_ms,ragdolls,npc_tracked` to `garrysmod/data/perfmesh_v2/metrics_<timestamp>.csv`.

`perfmesh_dump_state` writes a JSON snapshot capturing key cvars, controller log and job runtimes to `garrysmod/data/perfmesh_v2/state_<timestamp>.json`.

## Hold mode
Toggle `pm_pid_hold 1` to compute controller output without actuating. The UI badge shows **HOLD** while metrics continue updating.
