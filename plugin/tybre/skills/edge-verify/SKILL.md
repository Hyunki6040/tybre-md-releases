---
name: tybre-edge-verify
description: Use this when the user asks to "verify this crosslink", "check if this link is broken", "are these notes actually connected", or "audit crosslinks" in a Tybre.md vault. Read-only check of whether a `[[tybre://...]]` crosslink actually resolves and its anchor still exists, via the `tybre` CLI/MCP. Requires the `tybre` binary and the `tybre` skill.
---

# Edge verify

Checks whether a crosslink is actually valid — not just whether it parses,
but whether the target vault/file/anchor really exist right now. **Read-only:
never edits either file.** See the `tybre` skill's "Cross-project links"
section for the `tybre://`/`{…}` grammar this operates on.

## Input

- The file containing the crosslink(s) to check.
- Optionally, a specific target (`uuid` + `relpath`) to narrow to one link;
  default is every crosslink in the file.

## Procedure

1. Read the file (`read_file` MCP tool, or `tybre print <path>`) and
   identify each `[[tybre://<uuid>/<relpath>#anchor|alias]]` occurrence
   (plus its `{…}` meta, if any) by reading the returned text — this is
   reading, not re-implementing the link scanner.
2. For each, get its authoritative cross-status: prefer the `index_resolve`
   MCP tool when it's registered, otherwise `tybre index resolve
   tybre://<uuid>/<relpath>` from the CLI. This returns `resolved`,
   `pending`, or `broken`. **Do not** infer this from `tybre links report`
   — that report always marks crosslinks `broken` by design (it never
   cross-resolves; real cross-status is this project's job).
3. When `resolved`: read the target note (`read_file`/`tybre print` with
   `--project <uuid>`, or `tybre search <heading-or-block-id> --content
   --path-glob <relpath> --project <uuid>` as a lighter existence check)
   and confirm the `#anchor` (heading text, or `^block-id`) is actually
   present — a link can be "resolved" (file exists) while its anchor was
   renamed or deleted underneath it.
4. When `pending`: note that `tybre index heal <uuid>` forces a one-shot
   re-scan of that vault, then re-check once. Still `pending` after a heal
   usually means the target vault hasn't been opened on this machine
   recently enough to have a shard for it — not a broken link, just an
   unresolved one.
5. Produce one line per link: source `file:line`, target `project_uuid` +
   `relpath`, cross-status, and (when `resolved`) whether the anchor was
   found. Never write to either file.

## Notify the graph

State each checked link's target `project_uuid` explicitly in the report.
Verify is read-only, but it still *mentions* crosslinks, so after reporting
best-effort call, once per distinct target checked:

```
tybre notify-event crosslink_mention --project <this vault's uuid> --target <target uuid> --json
```

Ignore a failure/missing-command error from `notify-event` — it only drives
a graph animation and must never block or fail the verify report itself.
