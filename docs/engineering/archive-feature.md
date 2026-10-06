## What it does

`archive-feature` closes a finished feature. It reads the feature's spec and tickets, checks from the files alone that the work is really done, and after one confirmation sets the spec and tickets to `done` and moves the whole folder with `git mv` from `.scratch/<feature-slug>/` to `docs/archive/<feature-slug>/`. `.scratch/` is wiped from time to time, so the archive is where a finished feature survives until the deploy.

It never ticks a checkbox, never edits a ticket beyond its `Status:` line. The archive shows exactly what was done, not what the closing step assumed.

## When to reach for it

You invoke this by typing `/archive-feature`, and the agent won't reach for it on its own: archiving is your decision, so you are the one who calls it.

| You have | Run |
| --- | --- |
| One feature you just finished | `/archive-feature <feature-slug>` or `/archive-feature .scratch/<feature-slug>/SPEC.md` |
| Several features and no memory of which are done | `/archive-feature` with no argument: it reads every folder under `.scratch/` |
| A feature on GitHub, GitLab or Linear | Nothing here: the skill says it does not apply to a remote tracker and stops |

## Prerequisites

The local markdown tracker configured by [setup-skills](./setup-skills.md), with features under `.scratch/<feature-slug>/`. The skill creates `docs/archive/` and its README when they are missing. The `done` role comes from the triage labels that `setup-skills` writes.

## Ready means finished on paper

A feature with tickets is **ready** only when every ticket is `ready-for-human` or `done` and every checkbox in every ticket is ticked. The spec's own status is ignored, because it never moves during the flow. A feature without tickets cannot be judged from the files, so the skill asks you whether it was implemented.

You get one summary table: each feature as `ready` or with what is missing, plus folders without a `SPEC.md` listed as ignored. One confirmation archives every ready feature. An incomplete feature is archived only when you name it, and its spec then gets a dated note under `## Comments` listing what was left out, so whoever reads the archive later knows the gaps were deliberate.

## Common questions

**Why did it refuse to archive my feature?**

Something in the files says it is not finished: a ticket still `ready-for-agent`, or an unchecked box. The table lists each one. Finish it, or name the feature to archive it anyway.

**A destination already exists. What happens?**

That feature is skipped with a warning and the run carries on with the others. An older archive is never overwritten or merged.

**Does it commit?**

No. `git mv` stages the move and the status edits are plain modifications. Review them and commit yourself.

## It's working if

- You see one summary table before anything changes, and one confirmation question.
- Archived features are gone from `.scratch/` and present under `docs/archive/<feature-slug>/` with the same layout.
- Every ticket that met the rule says `Status: done`, and no checkbox changed.
- `git status` shows the moves and edits, and `git log` shows nothing new.

## Where it fits

A **chain step**, the last one: `grill-with-docs → to-spec → to-tickets → implement → archive-feature`. [implement](./implement.md) leaves tickets at `ready-for-human`, and this is what turns them into `done`. [ask-skills](./ask-skills.md) is the router over the whole set.
