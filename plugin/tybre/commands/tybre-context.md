---
description: Mandatory rules for handling [[tybre://…]] references passed from the Tybre.md graph — resolve and read them with the tybre CLI/MCP, never guess paths
argument-hint: "[tybre:// references + your request]"
disable-model-invocation: true
---

# /tybre-context

`$ARGUMENTS` is the user's request, usually prefixed with one or more
`[[tybre://<uuid>/<relpath>]]` note references picked in the Tybre.md graph
view. Treat the references as the context set for the request and follow
these rules for EVERY `tybre://` reference — they are cross-vault links, so
the file is often NOT under the current working directory:

1. **Never guess a filesystem path** from `<uuid>/<relpath>`. The uuid names
   another vault whose location on disk you don't know.
2. **Resolve first**: `tybre index resolve tybre://<uuid>/<relpath>` reports
   the link's live status (`resolved` / `pending` / `broken`). If the MCP
   server is available, the `index_resolve` tool (arguments `project_uuid`,
   `relpath`) is equivalent.
3. **Read the note**:
   - Same vault as the cwd → `tybre print <relpath>` or the MCP `read_file`
     tool with `path`.
   - Different / unopened vault → the MCP `read_file` tool with
     `project: "<uuid>"` and `path: "<relpath>"` (preferred), or
     `tybre search "<filename>" --project <uuid>` to locate related notes.
     `--project` accepts a uuid or an absolute vault path on `search`,
     `list`, `daily`/`weekly`/`monthly`, `chat`, and `links`.
4. **Edit edges, don't hand-edit syntax**: to remove or retune a crosslink
   use `tybre edge remove <file> <link>` / `tybre edge adjust <file> <link>
   [--rel <word>] [--str 0.0-1.0] [--relevance 0.0-1.0] [--why "<reason>"]`
   (`<link>` is the `tybre://…` target or the literal `[[tybre://…]]`).
   `edge adjust` REPLACES the whole meta block — pass the full desired set.
5. A `pending`/`broken` status is not a dead end: `tybre index heal <uuid>`
   re-scans that vault, then re-resolve before reporting a link as broken.

After gathering the referenced notes, carry out the rest of `$ARGUMENTS` as
the user's actual request, citing the notes you read.

Full CLI/MCP surface: `skills/tybre/SKILL.md` · `/tybre-help cli`.
