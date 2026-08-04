---
description: Mandatory rules for handling references injected by Tybre.md — [[tybre://…]] notes picked in the graph and [design:…] elements picked in the HTML preview. Resolve with the tybre CLI/MCP, never guess paths.
argument-hint: "[tybre:// refs and/or [design:…] tokens + your request]"
disable-model-invocation: true
---

# /tybre-context

`$ARGUMENTS` is the user's request, usually prefixed with references the
user picked inside Tybre.md: `[[tybre://<uuid>/<relpath>]]` notes from the
graph view, and/or `[design:"file" sel:"css path" …]` elements from the HTML
preview. Treat every reference as the context set for the request.

For `tybre://` references, follow these rules — they are cross-vault links,
so the file is often NOT under the current working directory:

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

For `[design:…]` tokens (HTML-preview element selections), the full grammar
and procedure live in the `tybre-design-select` skill
(`skills/design-select/SKILL.md`) — read it before acting. The essentials:

1. `design:"…"` names a project-relative HTML file; `sel:"…"` is a CSS path
   rooted at `<body>` that identified the clicked element (`:nth-of-type`
   counts same-tag siblings only). `text:"…"` is a 60-char excerpt for
   re-anchoring if the file changed since the click.
2. Read the file, locate exactly that element, and apply the user's request
   to it (or answer, if it's a question). Preserve unrelated markup.
3. Anything named `__tybre_*` / `data-tybre-*` is a preview-only artifact —
   it does not exist in the file; never add or "fix" it.

After gathering the referenced notes/elements, carry out the rest of
`$ARGUMENTS` as the user's actual request, citing what you read.

Full CLI/MCP surface: `skills/tybre/SKILL.md` · `/tybre-help cli`.
