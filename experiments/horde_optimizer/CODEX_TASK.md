# Codex Task: Harden Horde Optimizer (Garry's Mod)
Goal: Keep FPS stable under large zombie hordes without breaking behavior.

Deliverables:
1) Improve far/near classification (prefer engine-supported toggles; guard NextBot calls).
2) Optional ragdoll pooling (lightweight proxy instead of removal, if safe).
3) Per-class knobs via cfg/horde_optimizer.json (class -> overrides).
4) Packaging script: PowerShell `pack_addon.ps1` to zip `addon/` into `artifacts/horde_optimizer.zip`.
5) Self-check: `lua/autorun/server/horde_optimizer_selftest.lua`.

Constraints:
- Keep everything inside `experiments/horde_optimizer/`.
- No secrets. PRs only to `codex/horde-optimizer-sandbox`.
