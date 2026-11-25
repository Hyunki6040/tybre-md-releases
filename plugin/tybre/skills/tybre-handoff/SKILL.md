---
name: tybre-handoff
description: Use this when the user says "handoff", "hand off", "hand this to codex/claude", or wants to pass the current task to a fresh coding agent with full context, run by Tybre.md (`create_agent` MCP tool or `tybre run`). Requires the `tybre` binary and the `tybre` skill.
---

# Handoff

Transfer the current task — context, decisions, failed attempts, constraints —
to a fresh agent. The receiving agent starts with **zero context**, so the
prompt must be a self-contained briefing.

## Prerequisites

Call the `list_profiles` MCP tool before choosing who receives it and read
each profile's `whenToUse`. Do not create the agent until you have.

## Pick the receiver

1. **Profile** — a profile the user named; otherwise the one whose `whenToUse`
   fits the work. Create it with that profile's `provider`, `model` and `mode`.
   No profile fits → pick from `providers` (installed ones only).
2. **Isolation** — "in a worktree" → pass `worktree: { branch: "<short-branch>" }`
   (CLI: `--worktree <branch>`).
3. **Task** — everything else the user said.

## The briefing

```
## Task
[Imperative description.]

## Context
[Why this task exists.]

## Relevant files
- `path/to/file` — [what it is, why it matters]

## Current state
[Done / works / doesn't.]

## What was tried
- [Approach] — [why it failed or was dropped]

## Decisions
- [Decision — rationale]

## Acceptance criteria
- [ ] [Criterion]

## Constraints
- [Must-not / must-preserve]
```

**Keep the task's meaning.** Investigate-only → "DO NOT edit files." Fix →
"implement the fix." Refactor → "refactor, not rewrite."

## Launch

```
create_agent { provider, cwd, model?, mode?, title: "[Handoff] <task>",
               prompt: <briefing>, worktree?, notifyOnFinish: false }
```

CLI: `tybre run "<briefing>" --provider <p> --title "[Handoff] <task>" --no-wait`.

`notifyOnFinish: false` — it is the user's agent now, not your sub-agent.
Tell the user its id and that `tybre attach <id>` (or the app's agent panel)
shows it. Do not wait or poll.

Bypass permission modes are refused from here; the agent will ask the user
for permissions in the app.
