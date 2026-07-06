---
name: tybre-edge-disconnect
description: Use this when the user asks to "remove this crosslink", "disconnect this link", "delete the tybre:// link", or "unlink these notes" in a Tybre.md vault. Removes a `[[tybre://...]]` crosslink and its adjacent `{...}` edge metadata from a note, via the `tybre` MCP server / CLI. Requires the `tybre` binary and the `tybre` skill.
---

# Edge disconnect

Removes a crosslink (`[[tybre://<uuid>/<relpath>...]]`) and its adjacent
`{…}` edge-meta block from a note, as one unit — the "링크 제거" operation of
the crosslink patch contract (see the `tybre` skill's "Cross-project links"
section for the syntax). Only the direction authored in the file being
edited is removed; the reverse edge (if the target note authored one back)
is untouched.

## Input

- The source file (project-relative path, or an absolute path/uuid via
  `--project` for a note in a vault that isn't the current one).
- The crosslink to remove, identified by its target (`uuid` + `relpath`,
  and `#anchor`/`|alias` if the note has more than one link to the same
  target) or by pasting its literal `[[tybre://...]]` text.

## Procedure

1. Identify the crosslink to remove — its target
   `tybre://<uuid>/<relpath>[#anchor]`, or paste the literal
   `[[tybre://…]]` verbatim (the alias, if any, is stripped for matching).
2. Call the surgical remove — one command, no read-modify-write:

   ```
   tybre edge remove <file> "<tybre://uuid/relpath[#anchor]>" [--project <uuid|path>] --json
   ```

   This calls the crosslink patch contract's §4.4 surgical removal — the
   SAME internal patch (`edge_link_remove`) the app's Graph editor uses:
   it deletes the link + its adjacent `{…}` meta together (absorbing one
   leading space), preserves the rest of the line and the file's CRLF, and
   enforces the content-hash **reject-then-retry** itself. Do NOT read the
   file and rewrite it whole, and do NOT re-implement the conflict check or
   any span-editing in the skill — the shared patch owns all of that.
3. Read the JSON result:
   - `{"ok":true,"action":"removed",…}` → done.
   - `{"error":{"code":"conflict"}}` → the note changed underneath (rare,
     since locate+patch run in one call). Just re-run the exact same
     command once; it re-locates against the fresh content. Never track a
     hash or re-splice yourself.
   - `{"error":{"code":"not_found"}}` → the link isn't in the file (already
     removed, or wrong target/anchor). Report it — do not guess a location.
4. Report what was removed: source file + the removed link's target
   `project_uuid` + relpath.

## Notify the graph

Always state the target's `project_uuid` explicitly when reporting on a
crosslink. After the edit succeeds, best-effort call:

```
tybre notify-event crosslink_mention --project <this vault's uuid> --target <target uuid> --json
```

Ignore a failure/missing-command error from `notify-event` — it only drives
a graph animation and must never block or fail the disconnect itself.
