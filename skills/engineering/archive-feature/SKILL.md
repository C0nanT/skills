---
name: archive-feature
description: Close finished features (spec and tickets set to done) and move each whole from .scratch/ to docs/archive/, one named or all at once.
disable-model-invocation: true
---

# Archive Feature

Close finished features and move them out of `.scratch/` so they survive the periodic wipe. Works from the files only. Never ticks a checkbox, never edits ticket content other than the `Status:` line, never commits.

## Input

Optional. Either one feature, as a folder name (`.scratch/<feature-slug>/`) or a path to its `SPEC.md` (resolve both to the feature folder), or nothing.

- **One feature**: if the folder has no `SPEC.md`, it is not a feature: say so and stop. Then run steps 1 to 7 for it.
- **No argument**: run the [no-argument run](#no-argument-run) after step 1. Do not ask which feature to archive.

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

2. Run `git mv .scratch/<feature-slug> docs/archive/<feature-slug>`. The whole folder moves, layout untouched. If the folder is untracked, `git mv` fails: report it and stop rather than falling back to `mv`. In a no-argument run, this skips that feature and the run goes on.

## No-argument run

Steps 2 to 6 above are the same ones a single-feature run uses, applied per feature.

- **Scan.** List every folder directly under `.scratch/`. A folder with `SPEC.md` is a feature. A folder without it is listed as `ignored (no SPEC.md)` and left in place. Folders already archived are not here: they left `.scratch/`. If there are no features, say so and stop.
- **Check readiness** of each feature with step 2. A feature without tickets cannot be judged from the files: mark it `no tickets, will ask`.
- **Show one summary table**, one row per feature: the feature, then `ready`, or what is missing (each ticket with the wrong status, each unchecked box), or `no tickets, will ask`. Add the ignored folders. Mark a feature whose `docs/archive/<feature-slug>/` already exists as `destination exists, will be skipped`, whatever its readiness.
- **Resolve the no-ticket features.** Ask, for each, whether it was implemented. Yes moves it to the ready set, no moves it to the incomplete set.
- **Confirm once.** Ask a single confirmation to archive every ready feature, naming them. Declining archives none of them.
- **Incomplete features** are archived only when the user names them. Offer the choice once after the table, listing the incomplete features. Naming one is the "archive anyway" decision, so do not ask again: show its missing list in the report and run step 5's incomplete branch for it. An unnamed one is left untouched.
- **Archive each chosen feature**, one at a time, in this order: step 4 (destination check) first, then step 5, then step 6. A collision skips that feature with a warning before anything is edited, and the run continues with the others. Do not stop the run on one feature's failure: note it and go on.
- **Report.** Then run step 7 with the results of the whole run.

## 7. Report

Never commit. End with a report. For a no-argument run, one entry per feature, plus the ignored folders. Per feature: the feature archived and its new path, which tickets were set to `done`, which were left as they were and why, and whether a `## Comments` note was added. If a feature or the run stopped (remote tracker, destination exists, user chose to stop or left it out, no spec, `git mv` failed), say why. Remind the user the moved and edited files are staged or modified but uncommitted.
