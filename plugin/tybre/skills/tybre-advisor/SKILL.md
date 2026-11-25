---
name: tybre-advisor
description: Use this when the user says "advisor", "second opinion", "what does codex think", or wants an outside take on the current task without handing off the work. Spins up one read-only agent through Tybre.md (`create_agent` / `tybre run`). Requires the `tybre` binary and the `tybre` skill.
argument-hint: "[--profile <name>] <question or topic>"
---

# Advisor

One agent. Reads the situation. Gives a judgment. You decide — the advisor
doesn't drive the work.

## Prerequisites

Call `list_profiles` first and read each `whenToUse`. Do not create the
advisor before that.

## Pick the advisor

1. User named a profile (`--profile Reviewer`) → that one.
2. Otherwise the profile whose `whenToUse` fits: design/approach,
   audit/review, or research/root cause.
3. Several fit → prefer a different provider from your own, so the second
   opinion is actually fresh.

Create it with the profile's `provider`, `model`, `mode`. None fits → an
installed provider from `providers`.

## The briefing

Zero context on the other side. Include:

- The question, sharply.
- What you considered and ruled out.
- Relevant files by path (let it read them; don't paste).
- The ask: "give me a recommendation, with reasoning."

Always end with:

```
This is analysis only. Do NOT edit, create, or delete any files. Do NOT write code.
```

If the user's request names another skill (`/unslop`, `$diagnose`), tell the
advisor: "Invoke the `<name>` skill against this task. Load it before doing
anything else." Pass the remaining arguments as that skill's input.

## Launch and synthesize

```
create_agent { provider, cwd, title: "[Advisor] <topic>", prompt: <briefing> }
```

You're an agent, so you get a message when it finishes (`notifyOnFinish`
defaults to true) — go idle until then, or call `wait_for_agent` if you must
block. Read its answer, then give the user the advisor's verdict plus your
recommendation.

Want ongoing input? Keep it and `send_agent_prompt` follow-ups. Otherwise
`archive_agent` when done.

Note: an agent you created can't create agents of its own (one hop, like a
room's master → teammate). Ask it for analysis, not for more delegation.
