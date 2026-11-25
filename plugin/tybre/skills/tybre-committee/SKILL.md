---
name: tybre-committee
description: Use this when stuck, looping, tunnel-visioning, or facing a hard planning problem and the user wants a "committee" — two contrasting read-only agents (via Tybre.md `create_agent` / `tybre run`) that do root-cause analysis in parallel and converge on a plan. Requires the `tybre` binary and the `tybre` skill.
---

# Committee

Two agents from contrasting profiles, fresh context, planning in parallel.

## Prerequisites

Call `list_profiles` and read each `whenToUse` before creating anyone.
Contrast is the point: pick different providers when you can.

## Composition

- one whose `whenToUse` fits planning, research or root-cause analysis
- one contrasting high-reasoning profile on another provider

User named members → use those. Fewer than two fit → fill from installed
`providers` and tell the user.

## Hard rules

- **No edits.** Every prompt ends with:

  ```
  This is analysis only. Do NOT edit, create, or delete any files. Do NOT write code.
  ```

- **Trust the finish notification.** Don't poll, don't send hurry-ups, don't
  interrupt. Reasoning can take 15–30 minutes. Go idle; Tybre.md messages
  you when each one finishes (or needs a permission).

## Workflow

1. Write one problem-level prompt.
2. Create both at once: `create_agent { …, title: "[Committee] <task>", prompt }` ×2.
3. Wait for both finish messages.
4. Disagreements → `send_agent_prompt` each one the other's argument.
5. Repeat until they converge.

Give the user the consensus, where they diverged, and how it resolved.
`archive_agent` both when done.
