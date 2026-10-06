# 02: `archive-feature` closes one named feature

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** a new user-invoked skill `archive-feature` in `engineering/`. Given one feature (folder name or path to its `SPEC.md`), it checks readiness from the files: with tickets, every ticket `ready-for-human` or `done` and every checkbox ticked (the spec's status ignored); without tickets, it asks whether the feature was implemented. A ready feature gets `Status: done` on the spec and every ticket, then moves whole with `git mv` to `docs/archive/<feature-slug>/`, creating `docs/archive/` and its README (the convention from the `setup-skills` guide) when missing. An incomplete feature shows what is missing and the user chooses between stopping and archiving anyway; archiving anyway appends a dated `## Comments` entry to the spec listing what was left out, sets `done` only on the tickets that were ready, and leaves the others as they were. An existing destination folder stops the feature with a warning. A remote tracker stops the skill with a message. It never ticks a checkbox and never commits; it ends with a report of what moved and what was skipped.

**Seams:**
- End to end: a throwaway git repo with a fixture `.scratch/`, where the skill is invoked and the resulting files, statuses and report are read

**Blocked by:** 01 (the skill writes the `done` role)

Status: done

- [x] `SKILL.md` exists under `engineering/archive-feature/` with user-invoked frontmatter (`disable-model-invocation: true`) and `agents/openai.yaml` with `policy.allow_implicit_invocation: false`, per `.agents/invocation.md`
- [x] Accepts a folder name or a spec path
- [x] Ready feature with tickets: spec and tickets set to `done`, folder moved with `git mv`, layout untouched
- [x] Ticket still `ready-for-agent` or with an unchecked box: listed as missing, user asked; on "archive anyway", dated `## Comments` note in the spec, incomplete tickets keep their status
- [x] Feature without tickets: the skill asks whether it was implemented before closing
- [x] No checkbox changed in any case
- [x] Missing `docs/archive/` and README are created with the convention content
- [x] Existing `docs/archive/<feature-slug>/`: skipped with a warning, nothing overwritten or merged
- [x] Remote tracker configured: the skill says it does not apply and stops
- [x] Nothing is committed; final report lists archived and skipped features with reasons
- [x] Fixture run covering the cases above done and its result noted under `## Comments` in this ticket
- [x] No em-dashes

## Comments

### 2026-10-04: fixture run

Throwaway repos with fixtures staged and never committed (the git-guardrails hook blocks commits here, and `git mv` only needs the index). The procedure in `SKILL.md` was followed step by step inline, not by a separate model invocation. Results read from disk:

- Ready feature, no `docs/archive/`: spec and both tickets `done`, folder moved with `git mv`, `docs/archive/README.md` created with the convention text, checkboxes identical before and after.
- Incomplete feature (one ticket `ready-for-agent`, unchecked boxes), archive anyway: spec `done`, only the ready ticket `done`, the other two kept their status, dated `## Comments` entry appended, checkboxes untouched.
- No tickets, user answers "implemented": spec `done`, moved.
- Destination `docs/archive/dup/` exists: skipped with a warning, `.scratch/dup` and the old archive left as they were.
- Folder without `SPEC.md`: not a feature, stopped.
- Remote tracker in `docs/agents/issue-tracker.md`: skill says it does not apply and stops, nothing touched.
- No commit created in any repo. Observed: the created README is left untracked (not staged).
