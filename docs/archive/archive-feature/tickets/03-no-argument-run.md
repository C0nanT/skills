# 03: No-argument run across all of `.scratch/`

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** invoked with no argument, `archive-feature` reads every folder directly under `.scratch/`. Folders without `SPEC.md` are listed as "ignored (no SPEC.md)". It shows one summary table (feature, ready or the list of what is missing) and, after a single confirmation, archives every ready feature with the same closing and move rules as ticket 02. Incomplete features are archived only when the user names them, each going through the "archive anyway" path. Already archived features no longer appear, since they left `.scratch/`.

**Seams:**
- End to end: a throwaway git repo with a fixture `.scratch/`, where the skill is invoked and the resulting files, statuses and report are read

**Blocked by:** 02 (reuses its readiness check, closing and move)

Status: done

- [x] No argument reads every folder under `.scratch/`
- [x] Folders without `SPEC.md` appear as ignored and are left in place
- [x] Summary table shows each feature as ready or with what is missing
- [x] One confirmation archives all ready features
- [x] Incomplete features move only when named explicitly, with the `## Comments` note
- [x] A collision on one feature does not stop the others
- [x] Fixture run with several features (ready, incomplete, no tickets, no spec, colliding) done and its result noted under `## Comments` in this ticket
- [x] No em-dashes

## Comments

### 2026-10-04: fixture run

Throwaway repo with six `.scratch/` folders, staged and never committed. The procedure in `SKILL.md` was followed step by step inline (scripted), not by a separate model invocation. Results read from disk:

- Table: `ready` and `ready2` (one ticket already `done`) shown ready; `incomplete` listed with ticket 02 status and unchecked box; `notickets` marked "will ask"; `dup` marked "destination exists, will be skipped"; `techdebt` shown "ignored (no SPEC.md)".
- Single confirmation, `notickets` answered "implemented": `ready`, `ready2`, `notickets` moved to `docs/archive/`, spec and tickets `done`.
- `dup` collided: skipped with a warning, `.scratch/dup` and the old `docs/archive/dup` untouched, the run went on.
- `incomplete` named explicitly: spec `done`, only ticket 01 `done`, ticket 02 kept `ready-for-agent`, dated `## Comments` entry appended.
- `techdebt` left in place. Checkboxes unchanged, nothing committed.

### 2026-10-04: fixture run, second pass

After review the fixture got two more incomplete features, checked by script against the revised procedure (still not a separate model invocation, and no step 7 report text was produced, only the disk state read):

- `halfdone` (ticket `ready-for-agent`, unnamed): left untouched in `.scratch/`, statuses unchanged.
- `dupinc` (incomplete, destination `docs/archive/dupinc/` exists): the destination check hit first, so it was skipped before any `Status:` line was edited.

`SKILL.md` was changed after review: naming an incomplete feature is the "archive anyway" decision (no second prompt), the destination check runs before the close, and a failed `git mv` skips that feature in a no-argument run.
