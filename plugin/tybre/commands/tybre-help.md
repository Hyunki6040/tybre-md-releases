---
description: Show a topic summary of tybre CLI/MCP commands, tybre:// syntax, or the cross-project graph
argument-hint: "[syntax|cli|graph]"
disable-model-invocation: true
---

# /tybre-help

`$1` selects a topic: `syntax`, `cli`, or `graph`. No argument (or an
unrecognized one) → print all three summaries below. This is a static
reference — answer directly from the sections below, do not run tools or
re-derive the content.

## syntax — the `tybre://` crosslink + edge-meta grammar

- `[[tybre://<uuid>/<relpath>#anchor|alias]]` links to a note in **another**
  vault. `<uuid>` identifies the target vault (`tybre list projects` lists
  uuids known to this machine), `<relpath>` is the note's path inside that
  vault, `#anchor`/`|alias` are optional (same grammar as internal
  `[[relpath#heading|alias]]` links).
- Right after a link, `{rel:...; str:...; relevance:...; why:"..."}` attaches
  typed metadata to that one direction of the edge. All keys optional;
  `rel` is open vocabulary (`supports`/`refutes`/`related`/`cites`/`depends`/
  `derived`/`extends`/`contradicts` are the recommended set, for consistent
  graph coloring); `str`/`relevance` are 0.0–1.0 floats; `why` is a
  free-text reason.
- Full grammar + recommended-vocabulary table: `skills/tybre/SKILL.md` →
  "Cross-project links".
- To create, edit, remove, or verify a crosslink+meta pair, use the
  `edge-reconnect` / `edge-adjust` / `edge-disconnect` / `edge-verify`
  skills rather than hand-editing the markdown.

## cli — the `tybre` command line

- Notes: `tybre open <path>`, `tybre create <path> [--content <text>|-]`,
  `tybre print <path>`.
- Search: `tybre search <query> [--content] [--path-glob ...]
  [--frontmatter k=v] [--modified-after/-before <date>]
  [--project <dir|uuid>] [--json]`.
- Periodic notes: `tybre daily|weekly|monthly [--open]`.
- Links: `tybre links report` (orphans + broken links) / `tybre links fix
  <old> <new> [--apply]` (dry-run by default).
- Cross-project: `--project` on any command above accepts a vault's
  absolute path **or** its uuid, to read/write a vault that isn't the one
  currently open; `tybre index resolve <tybre://uuid/relpath>` and `tybre
  index heal <uuid>` check/refresh a crosslink's live cross-status.
- Full command list + flags: `skills/tybre/SKILL.md`, or `tybre --help` /
  `tybre <command> --help`.

## graph — cross-project graph + edge editing

- The app's Graph view renders every open vault's notes as one composite
  graph; crosslinks (`tybre://`) draw project-to-project edges, colored and
  weighted by `rel`/`str` (see `syntax` above).
- Editing an edge from Claude Code — rather than dragging in the Graph UI —
  is a skill, not a CLI flag:
  - `edge-reconnect` — add or restore a crosslink+meta at an anchor.
  - `edge-adjust` — change only `rel`/`str`/`relevance`/`why` on an
    existing crosslink; the link target itself is untouched.
  - `edge-disconnect` — remove a crosslink and its adjacent meta.
  - `edge-verify` — read-only: confirm a crosslink actually resolves and
    that its anchor still exists in the target note.
- Terminal `tybre` activity (a command, or an authored crosslink/edge-meta
  mention) is surfaced as a live particle on the graph via `tybre
  notify-event` — informational only, nothing you need to trigger yourself.
