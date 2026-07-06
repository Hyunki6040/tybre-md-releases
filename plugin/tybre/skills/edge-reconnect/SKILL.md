---
name: tybre-edge-reconnect
description: Use this when the user asks to "add a crosslink here", "connect this note to that project", "reconnect this broken link", or "link these two notes together" in a Tybre.md vault. Inserts a `[[tybre://...]]` crosslink (with optional `{...}` meta) at a given anchor — for a brand-new link, or to restore one `edge-verify` reported as broken. Requires the `tybre` binary and the `tybre` skill.
---

# Edge reconnect

Inserts a crosslink (+ optional edge meta) at a given anchor in the source
note — the "링크 추가" operation of the crosslink patch contract. Use it
either to author a brand-new cross-project link, or to restore one that
`edge-verify` reported `broken`/`pending` (after confirming with the user
what it should now point at — this skill never guesses a replacement
target). See the `tybre` skill's "Cross-project links" section for the
`tybre://`/`{…}` grammar.

## Input

- The source file, and the anchor **inside it** to insert under (a heading
  — required, since insertion needs a location; there is no "append to end
  of file" mode).
- The target: `uuid` + `relpath`, optional `#anchor`/`|alias`.
- Optional meta (`rel`/`str`/`relevance`/`why`).

## Procedure

1. Build the crosslink text: `[[tybre://<uuid>/<relpath>[#anchor][|alias]]]`
   followed immediately by `{…}` if meta was given.
2. Call the `write_file` MCP tool with `mode: append_to_heading` (or
   `prepend_to_heading`, if it should lead the section), `heading: <the
   source anchor>`, `content: <the crosslink text from step 1>`. This is
   an exact fit for "insert at anchor" — no manual read-modify-write cycle
   is needed, since this patch mode already does the surgical insert and
   already reports `heading_not_found`/`ambiguous_heading` cleanly if the
   anchor is wrong.
3. On a `heading_not_found`/`ambiguous_heading` error, re-read the file to
   confirm the exact heading text and retry once — this is correcting a
   stale/misremembered heading, not a write-conflict retry, since the
   append/prepend patch mode never destructively overwrites unrelated
   content.
4. Report the inserted link's target `project_uuid` + relpath, and where
   (which heading) it was inserted.

Natural follow-up to `edge-verify`: when it reports a link `broken`, offer
either this skill (reconnect it — after confirming the intended target) or
`edge-disconnect` (remove it instead).

## Notify the graph

State the target's `project_uuid` explicitly when reporting. After the
insert succeeds, best-effort call:

```
tybre notify-event crosslink_mention --project <this vault's uuid> --target <target uuid> --json
```

Ignore a failure/missing-command error from `notify-event` — it only drives
a graph animation and must never block or fail the reconnect itself.
