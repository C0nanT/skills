# 03: No-argument run across all of `.scratch/`

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** invoked with no argument, `archive-feature` reads every folder directly under `.scratch/`. Folders without `SPEC.md` are listed as "ignored (no SPEC.md)". It shows one summary table (feature, ready or the list of what is missing) and, after a single confirmation, archives every ready feature with the same closing and move rules as ticket 02. Incomplete features are archived only when the user names them, each going through the "archive anyway" path. Already archived features no longer appear, since they left `.scratch/`.

**Seams:**
- End to end: a throwaway git repo with a fixture `.scratch/`, where the skill is invoked and the resulting files, statuses and report are read

**Blocked by:** 02 (reuses its readiness check, closing and move)

Status: ready-for-agent

- [ ] No argument reads every folder under `.scratch/`
- [ ] Folders without `SPEC.md` appear as ignored and are left in place
- [ ] Summary table shows each feature as ready or with what is missing
- [ ] One confirmation archives all ready features
- [ ] Incomplete features move only when named explicitly, with the `## Comments` note
- [ ] A collision on one feature does not stop the others
- [ ] Fixture run with several features (ready, incomplete, no tickets, no spec, colliding) done and its result noted under `## Comments` in this ticket
- [ ] No em-dashes
