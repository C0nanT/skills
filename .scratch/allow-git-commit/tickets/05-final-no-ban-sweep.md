# 05: Final no-ban sweep

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** `../SPEC.md`

**What to build:** search-based confirmation that, across both repos, no commit ban remains and no instruction to commit was added, outside the historical areas (`.scratch/` of other features, `docs/archive/`, `CHANGELOG`s, `claude-hooks` CI/`release.sh`). Fix any straggler found.

**Seams:**
- `claude-hooks/test/run.sh` (rerun as a regression check)

**Blocked by:** 01, 02, 03, 04

Status: ready-for-human

- [x] Sweep of `skills/`, `.agents/`, `docs/` (minus `docs/archive/`), READMEs and `claude-hooks` for "never commit", "do not commit", "nunca commita", "não faz `git commit`", commit in a deny list or blocked pattern: zero hits that are a ban
- [x] Zero new instructions telling an agent to commit
- [x] `scripts/validate.sh` passes in `skills`
- [x] `bash test/run.sh` passes in `claude-hooks`
- [x] No em-dashes in prose edited by tickets 01 to 04
