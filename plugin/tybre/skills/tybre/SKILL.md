---
name: tybre
description: Use the `tybre` CLI to open, create, search, and print notes in a Tybre.md vault (a folder of markdown files). Use this when the user asks to open a note in Tybre.md, create/append a note, search their notes, or print a note's contents to the terminal. Requires the `tybre` binary on PATH (installed alongside the Tybre.md app).
---

# Tybre CLI

`tybre` is the command-line companion to the Tybre.md app. It operates on a
"vault" — a project folder of markdown files — either the current directory,
`--project <path>`, or the vault set via `tybre set-default`.

If the Tybre.md app is running, `tybre open`/`tybre create --open` reuse the
open window; otherwise they launch the app. All other subcommands work
headless (no app required) — the app's file watcher picks up the change
automatically if it's open.

## Commands

- **Open a note** (launches or reuses the app window):
  `tybre open <path> [--new-window] [--editor]`
  `--editor` opens in `$VISUAL`/`$EDITOR` instead of the app.

- **Create a note** (parent dirs auto-created):
  `tybre create <path> [--content <text>|-] [--open]`
  `--content -` reads the body from stdin (use for multi-line content,
  including frontmatter starting with `---`).

- **Search notes**:
  `tybre search <query> [--content] [--json] [--project <dir>]`
  Filename search by default; `--content` does full-text search across
  `.md`/`.txt` files (max 200 results).

- **Print a note's contents**:
  `tybre print <path> [--no-frontmatter]`

- **List projects or files**:
  `tybre list [projects|files] [--recursive] [--project <dir>]`

- **Periodic notes** (daily / weekly / monthly):
  `tybre daily [--open] [--project <dir>]`   → `<vault>/daily/YYYY-MM-DD.md`
  `tybre weekly [--open] [--project <dir>]`  → `<vault>/periodic/YYYY-Www.md` (ISO week)
  `tybre monthly [--open] [--project <dir>]` → `<vault>/periodic/YYYY-MM.md`
  Create-if-absent; never overwrite an existing note.

- **Structured search filters** (combine with `search`, all AND-ed):
  `tybre search <query> --content --path-glob "daily/**" --frontmatter status=draft --modified-after 2026-01-01 --json`
  `--path-glob` uses `*` (within a path segment), `**` (across segments), `?`
  (one char). `--frontmatter key=value` is repeatable. Dates are `YYYY-MM-DD` or
  unix seconds.

- **List command-palette entries**:
  `tybre commands [--json]` — lists the app's shortcut/command entries
  (`id`, title, keybinding, group). Listing only; execution is not exposed.

- **Chat** (run the agent CLI in the app terminal / headless):
  `tybre chat [prompt] [--project <dir>] [--json]`
  If the app is running, the prompt is delivered to the in-app terminal (the
  configured `claude_cli` runs and the prompt is bracket-pasted — never a shell
  string). If not, `claude` is launched headless with the prompt as a single
  argument. The CLI name is restricted to a bare-name allowlist for safety.

- **Links report & fix** (wikilink/relative-link graph):
  `tybre links report [--project <dir>] [--json]`
  Lists orphan notes (no links in or out) and broken links (as
  `file:line: target [broken|ambiguous]`).
  `tybre links fix <old> <new> [--project <dir>] [--dry-run|--apply] [--json]`
  Rewrites every reference to `<old>` so it points at `<new>` across the
  vault. **Dry-run by default** (prints the files that would change); pass
  `--apply` to write. Use after renaming/moving a note so `[[old]]` and
  `[text](./old.md)` references stay intact. `<old>`/`<new>` are vault-relative
  (or absolute) paths; `<new>` is the file's current on-disk location.

- **Default vault**:
  `tybre print-default` / `tybre set-default <path>`

## MCP server (alternative to shelling out)

`tybre mcp serve [--project <dir>]` runs a local, STDIO MCP server exposing
`list_files`, `read_file`, `write_file` (including surgical heading/frontmatter
patches), `search`, `open_in_app`, `open_folder`, and `open_remote_folder`
tools. This plugin's `.mcp.json` registers it — prefer the MCP tools over
shelling out to `tybre` when they're available, since they give structured
results and heading-level edits. Fall back to the CLI commands above for
anything the MCP tools don't cover (e.g. `open`, `daily`, project listing).

`open_folder` opens/switches the running app to a directory as a project
("폴더 열기") — absolute path for any project, vault-relative for a
subdirectory. `open_remote_folder` shows the app's remote-folder (SFTP)
connect dialog ("원격 폴더 열기"); the user fills in host/credentials there —
never pass credentials through the agent.

The `search` tool accepts the same structured filters as the CLI: `path_glob`,
`frontmatter` (an object of key→value equality), `modified_after`,
`modified_before`. Omit `query` to list files matching filters alone.

**HTTP transport (localhost only):** `tybre mcp serve --http [--port 4319]`
serves the identical tool set over `POST http://127.0.0.1/<port>/mcp`. It binds
loopback only and requires `Authorization: Bearer <token>` (the running app's IPC
token, or one printed to stderr on start). See the README for the `.mcp.json`
`type: http` entry.

## Inline tags (`#{tag}`)

Tags are authored as a **braced** token `#{tag}` (hash outside the brace)
anywhere in body text — the brace is required. A bare `#tag` is NOT a tag: it
stays a heading (`# Title`), a code comment (`#foo`), or a CSS colour
(`#FAFAF8`), none of which pollute the tag set. The hash-outside-brace shape is
deliberate: a kramdown/Pandoc heading-ID anchor `## Title {#id}` has the inverse
`{#…}` shape and is never mistaken for a tag. Frontmatter `tags:` (list or
comma-separated) also contributes.

- Tag chars: letters, digits, `_`, `-`, `/` (nesting, e.g. `#{area/backend}`).
- Adjacent tags allowed: `#{a}#{b}`. Purely-numeric (`#{123}`) is ignored.
- A `#{tag}` inside inline code (`` `#{sass}` ``) or a code fence is a sample,
  not a tag.
- The graph's tag filter and each note's `tags` come from this grammar only;
  the leading `#` is stripped in stored/queried values.

## Cross-project links (`tybre://`)

A wikilink can point at a note in a **different** vault, not just the one
you're working in: `[[tybre://<uuid>/<relpath>#anchor|alias]]`.

- `<uuid>` is the target vault's identity (a v4 UUID minted the first time
  that vault is opened — `tybre list projects` shows the uuids of vaults
  known to this machine).
- `<relpath>` is the target file's path relative to *its own* vault root,
  URL-encoded (spaces/`#`/`|`/unicode percent-escaped).
- `#anchor` is optional — a heading's text, or `^block-id` for a block
  reference (same anchor grammar as internal `[[relpath#heading]]` links).
- `|alias` is optional display text; omitted, the link renders as the
  relpath's filename stem.
- Example: `[[tybre://3fa85f64-5717-4562-b3fc-2c963f66afa6/design/api.md#Auth|API auth notes]]`

Right after a crosslink (or an internal wikilink), an optional `{…}` block
attaches typed metadata to **that one direction** of the edge only — the
reverse direction, if it exists, is authored separately in the target file:

```
{rel:supports; str:0.8; relevance:0.9; why:"cites the same benchmark"}
```

All four keys are optional and order-independent; unknown keys are ignored.
`rel` is an open vocabulary, but prefer these for consistent graph
coloring/icons:

| `rel` | Meaning | `rel` | Meaning |
|-------|---------|-------|---------|
| `supports` | Evidence/backing | `depends` | Prerequisite |
| `refutes` | Contradicts/rebuts | `derived` | Derived/produced from |
| `related` | Loose association | `extends` | Extends/elaborates |
| `cites` | Citation | `contradicts` | Conflicts (check both directions) |

`str` and `relevance` are 0.0–1.0 floats (connection strength / topical
relevance); `why` is a free-text quoted reason.

To create, edit, remove, or verify a crosslink+meta pair without hand-editing
the markdown, use the `edge-reconnect` / `edge-adjust` / `edge-disconnect` /
`edge-verify` skills — they call the same `tybre` CLI/MCP surface described
here rather than re-parsing the syntax.

### Reaching a project that isn't open

`--project` (on `search`, `list`, `daily`/`weekly`/`monthly`, `chat`,
`links`, and the MCP server's `project` argument) accepts **either** an
absolute path **or** a vault's uuid — use the uuid form to read/write a
vault that isn't the one currently open in the app, without knowing where it
lives on disk:

```
tybre search "auth flow" --project 3fa85f64-5717-4562-b3fc-2c963f66afa6 --content
```

A crosslink whose target vault this machine hasn't resolved yet reports
`pending`; check or refresh a link's real status with:

```
tybre index resolve tybre://<uuid>/<relpath>   # one link's live cross-status
tybre index heal <uuid>                        # force a re-scan of that vault
```

Reach for `index resolve` before trusting a crosslink's status (e.g. before
reporting it as broken), and `index heal` when a link that should resolve
keeps coming back `pending`/`broken` — most often because the target vault
moved or hasn't been opened on this machine recently.

## Notes

- All paths are relative to the vault root (or absolute).
- `tybre` never overwrites images/PDFs — only text files.
- If `tybre: command not found`, tell the user to install Tybre.md (which
  bundles the CLI) or add it to PATH.
