---
name: archive-feature
description: Close a finished feature (spec and tickets set to done) and move it whole from .scratch/ to docs/archive/.
disable-model-invocation: true
---

# Archive Feature

Close one finished feature and move it out of `.scratch/` so it survives the periodic wipe. Works from the files only. Never ticks a checkbox, never edits ticket content other than the `Status:` line, never commits.

## Input

One feature, as either a folder name (`.scratch/<feature-slug>/`) or a path to its `SPEC.md`. Resolve both to the feature folder. If the user passed nothing, ask which feature to archive. If the folder has no `SPEC.md`, it is not a feature: say so and stop.

## 1. Tracker check

If `docs/agents/issue-tracker.md` exists and names a tracker other than local markdown (GitHub, GitLab, Linear, ...), say this skill does not apply to a remote tracker and stop. Touch nothing.

## 2. Check readiness

Read the spec and every file in `.scratch/<feature-slug>/tickets/`.

- **With tickets**: ready only when every ticket's `Status:` is `ready-for-human` or `done` **and** every checkbox in every ticket is ticked (`- [x]`). The spec's own status is ignored: it never moves in the current flow. For each ticket that fails, record what is missing: its status, and each unchecked box.
- **Without tickets**: the files cannot tell. Ask the user whether the feature was implemented. Yes counts as ready, no counts as incomplete.

## 3. Decide

- **Ready**: continue.
- **Incomplete**: show what is missing (tickets with the wrong status, unchecked boxes) and ask the user to choose between stopping and archiving anyway. Stopping ends the run with nothing changed.

## 4. Check the destination

If `docs/archive/<feature-slug>/` already exists, stop with a warning. Never overwrite or merge. Nothing has been changed yet at this point.

## 5. Close

Set the status lines. `Status:` is the line near the top of the spec and of each ticket; replace its value, never anything else.

- Ready feature: `Status: done` on the spec and on every ticket.
- Incomplete feature archived anyway: `Status: done` on the spec and **only** on the tickets that met the readiness rule. Tickets that did not keep their current status. Append a `## Comments` entry at the bottom of the spec (create the heading if missing), dated today, listing each ticket and unchecked item that was left out. For a feature without tickets, the entry says the user confirmed it was not fully implemented.

Never tick or untick a checkbox, in any case.

## 6. Move

1. If `docs/archive/` is missing, create it. If `docs/archive/README.md` is missing, create it with exactly:

   ```markdown
   # Archive

   Finished features moved out of `.scratch/` for later review: post-deploy checklists, frontend handoffs, specs and tickets worth keeping in the repo.

   - One feature per directory: `docs/archive/<feature-slug>/`, same layout it had in `.scratch/` (`SPEC.md`, `tickets/`, `POST-DEPLOY.md`, handoffs…).
   - Moved by the maintainer, as-is. Not a triage surface: nothing here is active work.
   ```

2. Run `git mv .scratch/<feature-slug> docs/archive/<feature-slug>`. The whole folder moves, layout untouched. If the folder is untracked, `git mv` fails: report it and stop rather than falling back to `mv`.

## 7. Report

Never commit. End with a report: the feature archived and its new path, which tickets were set to `done`, which were left as they were and why, and whether a `## Comments` note was added. If the run stopped (remote tracker, destination exists, user chose to stop, no spec), say why. Remind the user the moved and edited files are staged or modified but uncommitted.
