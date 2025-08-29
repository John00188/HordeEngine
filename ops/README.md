# ops/ — Shared Communication Bus

A tiny, in-repo coordination layer so multiple automation actors (Agent Mode, Codex, or humans)
can cooperate safely without stepping on each other.

## Files
- `comms.json` — **authoritative shared state** (agents, work items, PR URLs, artifact links).
- `log.md` — append-only human/agent log of state transitions and notable actions.
- `locks/` — lock files for individual work items to avoid collisions (see `locks/README.md`).

## Operating Rules
- Single source of truth: read & write `ops/comms.json`.
- Only modify your own agent object and the work items you **have locked**.
- State machine for work items: `queued → in_progress → blocked|review → merged → released`.
- Always append a one-liner to `ops/log.md` when you change something.
- Redact any secrets or tokens in logs and notes.
