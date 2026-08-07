---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

If triage labels or tracker conventions are needed and missing, run `/setup-skills`. Destination resolution below does not require setup.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Rate each ticket's difficulty

Give every ticket a **difficulty tier** and a **suggested model** for whoever picks it up. The suggestion is a hint, never a requirement — the reader may be in Claude Code, in Cursor, or somewhere else, so name a model per tool and let them substitute.

<difficulty-tiers>

| Tier | What lands here | Suggested model |
| --- | --- | --- |
| **Heavy** | Infrastructure, deploys, migrations, architecture decisions, security boundaries, wide refactors, anything whose blast radius crosses subsystems | Opus (Claude Code) / Opus or the strongest reasoning model available (Cursor) |
| **Standard** | Ordinary programming logic — a feature slice, an endpoint, a component, a bug fix with real branching. The default tier, and where most tickets belong | Sonnet (Claude Code) / Sonnet (Cursor) |
| **Light** | Mechanical, low-judgement work — config bumps, copy changes, renames with a small blast radius, adding a test that mirrors an existing one | Haiku (Claude Code) / Composer or another fast cheap model (Cursor) |

</difficulty-tiers>

Rate on the **judgement** the ticket demands, not on the diff size — a one-line change to a deploy pipeline is Heavy, and a 400-line component that follows an existing pattern is Standard. When a ticket sits between two tiers, pick the higher one. If most tickets in a run come out Heavy, the slices are probably too wide — revisit step 3.

### 5. Show the breakdown

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Difficulty**: the tier and the suggested model
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

**Do not ask for confirmation before publishing.** Publish straight after showing the list — no "does this look good?" pause. Only stop and iterate with the user first if they explicitly asked to review or approve the breakdown before publishing for this run.

### 6. Publish the tickets

**Resolve where to publish — do not ask.** Pick silently:

1. If the user explicitly asked this run to publish to GitHub, GitLab, local markdown, or another tracker — use that.
2. Else if `docs/agents/issue-tracker.md` exists (written by `/setup-skills`) and names a tracker — use that.
3. Else — **Local markdown**. Do not probe `git remote`. Do not present a destination picker.

The tickets are the same either way; only the shape of the blocking edges changes:

- **Local markdown** → write one file per ticket under `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below — one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, GitLab, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Follow `docs/agents/issue-tracker.md` when present. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise — the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

```markdown
# <NN> — <Ticket title>

> **Difficulty:** Heavy | Standard | Light — **suggested model:** <model> (Claude Code) / <model> (Cursor). Suggestion only — use whatever model you have to hand.

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2
```

</local-ticket-template>

<issue-template>

> **Difficulty:** Heavy | Standard | Light — **suggested model:** <model> (Claude Code) / <model> (Cursor). Suggestion only — use whatever model you have to hand.

The difficulty line is the first thing in the issue body, above every section.

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

</issue-template>

In either form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.
