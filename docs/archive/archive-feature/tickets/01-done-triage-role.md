# 01: `done` triage role

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** the triage vocabulary gains a sixth role, `done` ("work finished and accepted; set by `archive-feature`"), both in this repo's triage labels file and in the triage labels template that `setup-skills` writes into other repos. Any prose that counts "five canonical roles" now says six. Prefactor for the skill: nothing reads or writes `done` yet.

**Seams:**
- None (vocabulary change only, verified by reading the files)

**Blocked by:** None (can start immediately)

Status: done

- [x] This repo's triage labels table has a `done` row with its meaning
- [x] The `setup-skills` triage labels template has the same row
- [x] No prose in the repo still says the vocabulary has five roles (grep for "five")
- [x] Docs page for `setup-skills` re-synced if it lists the roles
- [x] No em-dashes added
