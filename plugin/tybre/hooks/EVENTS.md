# Tybre hook event contract (CLI-104)

This document formalizes the **event surface** a Claude Code hook (or any
consumer) can react to when working against a Tybre.md vault. It is the
Tybre analogue of Obsidian's `registerEvent(file-save / file-open / …)`.

## Extension model (decision record)

Tybre's extension model is **declarative command hooks** — you match an event
and run a `tybre` command (or any shell command). This mirrors Claude Code's
native `PostToolUse`/`PreToolUse` hooks and Obsidian's `registerEvent`.

We deliberately **reject a WASM/native plugin runtime** (Zed-style): Tybre is
local-first, the maintenance surface of a sandboxed plugin VM is large, and the
agent-integration story is already fully served by the CLI + MCP server. This
closes the extension-model question delegated from TD-CL. (See
`docs/prd/30-cli.md` CLI-104.)

## Events

Each event flows **app → consumer** (Tybre emits, a hook consumes). Stability:

| Event            | Stability | Backing app signal        | Raw payload |
|------------------|-----------|---------------------------|-------------|
| `file-save`      | stable    | Tauri `file-changed` (watcher) on a saved path | `string` (absolute path) |
| `file-open`      | stable    | Tauri `open-files`        | `string[]` (absolute paths) |
| `tab-change`     | reserved  | (no app event yet)        | `{ "path": string, "tabId": string }` |
| `graph-activity` | stable    | Tauri `tybre://graph-activity` (emitted by `tybre notify-event` over IPC) | `{ kind, project_uuid, target_uuid?, path?, ts }` |

The **Raw payload** column is exactly what the backing Tauri event carries today
(`watcher.rs` emits `file-changed` as a bare string; `lib.rs`/`ipc.rs` emit
`open-files` as a bare string array). Deserialize against these shapes, not an
object wrapper.

- **`file-save`** — fires when a markdown file in the open project is written
  (by the editor's auto-save, an external edit, or the `tybre` CLI). The payload
  is the absolute path string. Use it to re-index links, warm search, or notify
  an agent.
- **`file-open`** — fires when the app is asked to open one or more files (deep
  link, `tybre open`, "Open with Tybre.md"). The payload is an array of absolute
  path strings.
- **`tab-change`** — **reserved**: the contract (name + payload) is fixed so
  hooks can be written against it, but the app does not yet emit it. Treat it as
  future scope; do not depend on it firing.
- **`graph-activity`** (XC-105 / TD-XA) — fires when `tybre notify-event <kind>`
  reaches the running app over IPC. It drives the **neural graph animation**
  (43/XG-107): the graph fires directional particles on the referenced edge and
  glows the referenced node. UNLIKE the events above, this one is **published by
  a CLI/hook**, not by an app UI action — a `PostToolUse` hook calls
  `tybre notify-event` and the app re-emits the structured payload to the graph.
  Publishing goes through the **existing IPC socket** (the same path as
  `tybre open` / `tybre chat`) — no new network transport (TD-CL / TD-XA). When
  the app is closed, `tybre notify-event` is a silent no-op (exit 0).

## How to consume

Claude Code hooks don't subscribe to Tybre's Tauri events directly — they hook
Claude's own tool lifecycle (`PostToolUse` on `Write`/`Edit`) and then call a
`tybre` command. That's the practical, shipping integration; see
[`hooks.json`](./hooks.json) and [`examples/`](./examples/). A future first-party
bridge could forward these Tauri events to an external process, but the contract
above is the stable target either way.

## Payload schemas (JSON)

```jsonc
// file-save — bare absolute-path string
"/abs/path/to/note.md"

// file-open — bare array of absolute-path strings
["/abs/path/a.md", "/abs/path/b.md"]

// tab-change (reserved — not emitted yet)
{ "path": "/abs/path/note.md", "tabId": "tab-123" }

// graph-activity — structured neural-animation event (XC-105)
{
  "kind": "cli_command",   // "cli_command" | "crosslink_mention" | "syntax_mention"
  "project_uuid": "…",     // acting project uuid ("" when only a path is known)
  "target_uuid": null,     // crosslink target uuid, or null
  "path": "/abs/project",  // path hint (project dir or file), or null
  "ts": 1751600000000      // epoch millis, app-stamped
}
```

## Publishing graph-activity (`tybre notify-event`)

`tybre notify-event <kind> [--project <uuid>] [--target <uuid>] [--path <p>] [--json]`

- `<kind>` is one of `cli_command`, `crosslink_mention`, `syntax_mention`
  (validated; any other value errors). Everything else is optional.
- `--project` / `--target` are **project uuids** (40 TD-XH). `--path` is a
  fallback the graph resolves to a uuid when `--project` is omitted (e.g. a
  hook only knows `$CLAUDE_PROJECT_DIR`).
- The call reaches the running app over the **same IPC socket** as `tybre open`
  (30-cli.md CLI-020); it opens **no** new socket/port. With no app running it
  exits 0 and does nothing — safe to fire from a hook on every command.

Recommended hook (see [`hooks.json`](./hooks.json) `//examples.post_bash_notify_graph`):
grep the Bash tool's stdin JSON for a `tybre `/`tybre://` marker, then notify.
`grep` reads the payload without a `jq` dependency; extract `.tool_input.command`
with `jq` if you need to key off the exact command string.
