---
name: tybre-edge-adjust
description: Use this when the user asks to "change the relationship type", "update this link's strength/relevance", "add a reason for this link", or "edit the crosslink metadata" in a Tybre.md vault. Updates only the `{rel;str;relevance;why}` edge-meta block of an existing `[[tybre://...]]` crosslink — the link target itself is untouched. Requires the `tybre` binary and the `tybre` skill.
---

# Edge adjust

Changes only the `{…}` edge metadata (`rel`/`str`/`relevance`/`why`) of an
existing crosslink — the "메타 수정" operation of the crosslink patch
contract. The link's target (uuid/relpath/anchor/alias) is never touched by
this skill. To repoint a link at a different target, use `edge-disconnect`
then `edge-reconnect` instead. See the `tybre` skill's "Cross-project links"
section for the `{…}` grammar and recommended `rel` vocabulary.

## Input

- The file containing the crosslink (project-relative, or `--project
  <uuid|path>` for a note in another vault).
- The crosslink whose meta should change, identified by its target
  (`uuid` + `relpath`, and `#anchor`/`|alias` if ambiguous) or its literal
  `[[tybre://...]]` text.
- The new meta values: any subset of `rel`/`str`/`relevance`/`why`. A key
  left unset is cleared (the edge-meta struct's fields are all optional —
  there is no "leave as-is" sentinel, so state the full desired set, not
  just the changed key).

## Procedure

1. Identify the crosslink whose meta changes — its target
   `tybre://<uuid>/<relpath>[#anchor]`, or paste the literal
   `[[tybre://…]]`. A link with no meta yet is a valid target (this skill
   also handles "add meta to a bare link").
2. Call the surgical meta update — one command, no read-modify-write. Pass
   the full desired set (any key you omit is cleared):

   ```
   tybre edge adjust <file> "<tybre://uuid/relpath[#anchor]>" \
     [--rel <type>] [--str <0.0–1.0>] [--relevance <0.0–1.0>] \
     [--why "<free text>"] [--project <uuid|path>] --json
   ```

   This calls the crosslink patch contract's §4.4 "메타 수정" — the SAME
   internal patch (`edge_meta_update`) the app's Graph editor uses: it
   inserts the `{…}` block right after the link, or replaces the one
   already there (an all-empty set removes it), preserves the file's CRLF,
   and enforces the content-hash **reject-then-retry** itself. Do NOT
   rewrite the file whole, and do NOT re-implement the conflict check or
   `{…}` splicing in the skill — the shared patch owns all of that.
3. Read the JSON result:
   - `{"ok":true,"action":"adjusted","meta":{…}}` → done.
   - `{"error":{"code":"conflict"}}` → the note changed underneath (rare).
     Re-run the exact same command once; never track a hash yourself.
   - `{"error":{"code":"not_found"}}` → the link isn't in the file. Report
     it — do not guess a location.
4. Report the target link and the old → new meta values.

## Notify the graph

State the target's `project_uuid` explicitly when reporting. After the edit
succeeds, best-effort call:

```
tybre notify-event crosslink_mention --project <this vault's uuid> --target <target uuid> --json
```

Ignore a failure/missing-command error from `notify-event` — it only drives
a graph animation and must never block or fail the adjust itself.
