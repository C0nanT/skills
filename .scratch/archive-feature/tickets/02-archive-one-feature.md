# 02: `archive-feature` closes one named feature

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** a new user-invoked skill `archive-feature` in `engineering/`. Given one feature (folder name or path to its `SPEC.md`), it checks readiness from the files: with tickets, every ticket `ready-for-human` or `done` and every checkbox ticked (the spec's status ignored); without tickets, it asks whether the feature was implemented. A ready feature gets `Status: done` on the spec and every ticket, then moves whole with `git mv` to `docs/archive/<feature-slug>/`, creating `docs/archive/` and its README (the convention from the `setup-skills` guide) when missing. An incomplete feature shows what is missing and the user chooses between stopping and archiving anyway; archiving anyway appends a dated `## Comments` entry to the spec listing what was left out, sets `done` only on the tickets that were ready, and leaves the others as they were. An existing destination folder stops the feature with a warning. A remote tracker stops the skill with a message. It never ticks a checkbox and never commits; it ends with a report of what moved and what was skipped.

**Seams:**
- End to end: a throwaway git repo with a fixture `.scratch/`, where the skill is invoked and the resulting files, statuses and report are read

**Blocked by:** 01 (the skill writes the `done` role)

Status: ready-for-agent

- [ ] `SKILL.md` exists under `engineering/archive-feature/` with user-invoked frontmatter (`disable-model-invocation: true`) and `agents/openai.yaml` with `policy.allow_implicit_invocation: false`, per `.agents/invocation.md`
- [ ] Accepts a folder name or a spec path
- [ ] Ready feature with tickets: spec and tickets set to `done`, folder moved with `git mv`, layout untouched
- [ ] Ticket still `ready-for-agent` or with an unchecked box: listed as missing, user asked; on "archive anyway", dated `## Comments` note in the spec, incomplete tickets keep their status
- [ ] Feature without tickets: the skill asks whether it was implemented before closing
- [ ] No checkbox changed in any case
- [ ] Missing `docs/archive/` and README are created with the convention content
- [ ] Existing `docs/archive/<feature-slug>/`: skipped with a warning, nothing overwritten or merged
- [ ] Remote tracker configured: the skill says it does not apply and stops
- [ ] Nothing is committed; final report lists archived and skipped features with reasons
- [ ] Fixture run covering the cases above done and its result noted under `## Comments` in this ticket
- [ ] No em-dashes
