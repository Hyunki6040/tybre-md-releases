---
name: tybre-help
description: Use this when the user asks how Tybre.md itself works or why it is broken — app/CLI setup, "tybre: Tybre.md isn't running", agents that won't start, providers not found, MCP not connecting, resident mode, logs. To operate notes, agents or terminals use the `tybre` skill instead.
---

# Tybre.md help

Help the user understand, configure or fix Tybre.md. Answer directly; check
the facts against the running install, not memory.

## Ground truth first

`tybre manifest` prints every CLI command, flag and MCP tool of the
installed version — use it instead of guessing a command. Then the smallest
read-only checks:

```bash
tybre --version
tybre doctor --json          # app/IPC, vault, MCP registration, PATH, with fixes
tybre daemon status --json   # is the app (or its hidden resident mode) up
```

Most "CLI can't reach the app" problems are: app not running (→
`tybre daemon start` runs it hidden in the tray), or a CLI newer/older than
the app (`unknown_command` / `protocol_mismatch` → update so both match).

## Agents

- `tybre ps` lists agents with lifecycle and attention; `tybre logs <id>`
  shows what one did; `tybre wait <id>` exits 3 when it waits for a
  permission (`tybre permit <id>` answers it).
- Provider missing → check that its CLI (`claude`, `codex`, …) runs in a
  fresh login shell; `list_profiles` shows which providers the app found.
- "bypass … interactive" errors are deliberate: bypass modes only work in
  a session the user opened in the app, never from CLI/MCP/schedules.
- "delegation too deep": a sub-agent can't create its own sub-agents.

## Files

- Global settings: `~/Library/Application Support/Tybre/config.json` (macOS)
- Per project: `.tybre/` in the project folder (tabs, workspace, graph)
- Resident-mode log: `tybre daemon logs -n 200`

Read the narrowest slice; redact tokens and keys before showing a log.

## Don't change state silently

Don't restart the app, edit config, or update anything without the user's
OK — restarting the app can kill the agent doing the diagnosis.

Not resolved → collect app and CLI versions, OS, the exact error, steps to
reproduce, and a short redacted log excerpt for a bug report.
