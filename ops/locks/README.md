This folder holds ephemeral lock files for individual work items.

Lock file path: `ops/locks/<work-item-id>.lock`

JSON payload example:
```json
{"owner":"AgentMode|Codex","ts":"2025-08-29T22:00:00Z","ttl_s":900}
```

Rules:
- If a lock exists and `now - ts < ttl_s`, respect it and do not take the task.
- If the lock is expired, you may overwrite it and proceed (record the overwrite in ops/log.md).
- Release the lock by deleting the file after you complete your commit/PR for this item.
