# DSH Session Manager

Local dual-face Cordis plugin for the DeepSeek Harness Web GUI.

## UI

- Adds **Settings → 会话管理** with search, archive/unarchive, deletion scheduling, trash restore, and permanent trash purge.
- Adds an **归档** action to the current conversation header.
- Displays live/running, archived, pending-delete, workspace, and subagent status.

## Deletion safety

DSH 0.1.1-rc.2 has no public session-deletion or unarchive API. The plugin therefore:

1. archives a session immediately;
2. records the session and all descendants in a plugin-owned pending-delete journal;
3. on the next Harness startup, before browser-driven session resume, moves cold JSONL session directories to `$DSH_HOME/session-trash`;
4. keeps a manifest that allows restoration;
5. permanently removes files only when the user explicitly purges a trash entry.

This avoids moving a log while the current process may still be writing it. Attachments and other content-addressed shared data are intentionally not garbage-collected.

The unarchive operation uses the pinned rc.2 WorkspaceRegistry state write path because that release exposes archive but not unarchive publicly. A future DSH upgrade should replace this compatibility path with a public API when available.

## Host routes

Same-origin JSON routes owned by the plugin:

- `GET /session-manager/api/sessions`
- `POST /session-manager/api/action`

The Web server is loopback-only in this configuration. Mutating requests use `application/json`, check the browser Origin against Host when present, and do not enable CORS.
