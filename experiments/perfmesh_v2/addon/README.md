# PerfMesh v2 (Control Plane)
- Scheduler v2 with time-slice fairness and EMA metrics
- Policies: ragdoll cap, NPC pacing, optional shadow disable
- Adaptive manager that tightens/loosens based on budget headroom

Console:
- perfmesh_status
- perfmesh_metrics
- pm_policy_status

Main CVars:
- pm_tick_budget_ms (default 2.5)
- pm_ragdoll_max (default 25)
- pm_far_distance (default 2200)
- pm_think_hz_near (12), pm_think_hz_far (3)
- pm_npc_no_shadows (1)
- pm_adaptive (1), pm_aggressiveness (0..3)
