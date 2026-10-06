# 02: setup-skills stops seeding commit

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** `../SPEC.md`

**What to build:** running `/setup-skills` with Section D (Git guardrails) set to "yes" on a new project produces a deny list without any commit rule, and everything the user reads (Section D explainer, the `### Git guardrails` sub-block in CLAUDE.md/AGENTS.md, the `git-guardrails.md` written to the project) stops citing commit. No logic to remove commit rules from projects that already have them.

**Seams:**
- None (prose and seed list; verified by the criteria below)

**Blocked by:** None (can start immediately)

Status: done

- [x] The seed list (text block and jq array) no longer contains `Bash(git commit *)`, `Bash(git -C * commit)` or `Bash(git -C * commit *)`
- [x] The `git-guardrails.md` template no longer lists any commit rule
- [x] The Section D explainer and the `### Git guardrails` sub-block no longer mention commit; the sub-block's example list starts with another command (e.g. `push`)
- [x] The "Skip when the deny rules already exist" detection stays consistent with the new list
- [x] The `setup-skills` docs page (re-synced per `.agents/writing-docs.md`) and the `setup-skills` guides (en and pt-br) no longer say commit is refused
- [x] No text tells the agent to commit
- [x] No em-dashes in the edited prose
