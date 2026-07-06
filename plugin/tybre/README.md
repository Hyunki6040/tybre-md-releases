# Tybre Claude Code plugin

Lets Claude Code talk to a [Tybre.md](https://github.com/Hyunki6040/tybre-md-releases)
vault (a folder of markdown notes) via the bundled `tybre` CLI / MCP server.

Requires the `tybre` binary on PATH (it ships with the Tybre.md app, next to
the app binary). Check with `tybre --version`.

## What's included

- **`skills/tybre/SKILL.md`** — teaches Claude when/how to use the `tybre`
  CLI (open/create/search/print notes), the MCP tools below, and the
  `tybre://` cross-project link + edge-meta syntax.
- **`skills/edge-{disconnect,verify,adjust,reconnect}/SKILL.md`** — narrow
  skills for editing/checking a crosslink's `{rel;str;relevance;why}` meta
  or target without hand-editing markdown.
- **`commands/tybre-help.md`** — `/tybre-help [syntax|cli|graph]`, a static
  one-command reference (manual-only — not invoked automatically by Claude).
- **`.mcp.json`** — registers `tybre mcp serve` as a local STDIO MCP server
  exposing `list_files`, `read_file`, `write_file` (surgical heading/
  frontmatter patches), `search`, `open_in_app`. No network, no daemon — it's
  a plain subprocess Claude Code starts and talks to over stdin/stdout.
- **`hooks/hooks.json`** + **`hooks/EVENTS.md`** + **`hooks/examples/`** — the
  hook event contract (`file-save` / `file-open` / `tab-change`) and ready-to-copy
  opt-in examples. Nothing runs unless you copy an example into your own settings
  and enable it. `EVENTS.md` also records the extension-model decision
  (declarative command hooks; no WASM runtime).

## Install

### Option A — Claude Code plugin marketplace

```
/plugin marketplace add Hyunki6040/tybre-md-releases
/plugin install tybre@tybre-md-releases
```

See [`INSTALL.md`](./INSTALL.md) for prerequisites, updating, and a
4-language summary (ko/es/zh).

### Option B — register the MCP server directly, no plugin install

Add to your project's `.mcp.json` (or run `claude mcp add`):

```json
{
  "mcpServers": {
    "tybre": {
      "type": "stdio",
      "command": "tybre",
      "args": ["mcp", "serve", "--project", "/absolute/path/to/vault"]
    }
  }
}
```

Drop `--project` to let `tybre` fall back to the current working directory or
your configured default vault (`tybre set-default <path>`).

### Option C — HTTP transport (localhost only)

Run `tybre mcp serve --http --port 4319 --project /abs/path/to/vault`. It binds
`127.0.0.1` only and requires a bearer token (reuses the running app's IPC token,
or prints a fresh one to stderr on start). Register it as an `http` server:

```json
{
  "mcpServers": {
    "tybre": {
      "type": "http",
      "url": "http://127.0.0.1:4319/mcp",
      "headers": { "Authorization": "Bearer <token>" }
    }
  }
}
```

Get the token from the server's stderr banner (`auth token …`), or — when the
Tybre.md app is running — from its IPC lock file
(`<config>/cli-ipc.json` → `"token"`). The server is never reachable off the
machine; there is no way to bind a non-loopback interface.

The Tybre.md app itself can do this for you: open a project, and if Claude
Code is detected but not yet registered, the app offers a one-click
"Register with Claude Code" action (Settings → Terminal has an "auto-register"
toggle if you'd rather it happen silently for every project).

## Uninstall / unregister

Remove the `tybre` entry from `.mcp.json`, or use the "Unregister" button in
Tybre.md's Settings → Terminal section.
