# 03: Unlock the isolation flow (implement, review-axes, delegate-tickets)

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** `../SPEC.md`

**What to build:** `/implement`, `/review-axes` and `/delegate-tickets` stop forbidding any git command to the agent (`add`, `commit`, `reset`, `stash`, `checkout`, "never anything that moves the index", "Never make a commit"), while keeping the mechanism they describe: the `git stash create` snapshot and restore via `git restore --source`, review over the unstaged working tree with `git add -N .`, and the orchestrator's `git add -A` baseline protocol (with confirmation). Phrases like "never commits", "Nothing is ever committed", "since neither commits" become neutral descriptions. No step instructs committing; `implement` keeps the Verdict and the Conventional Commits message.

**Seams:**
- None (skill prose; verified by the criteria below)

**Blocked by:** None (can start immediately)

Status: done

- [x] `implement`: Report step without "Never make a commit"; refactor step without "without committing" and without the ban list; Review step passes the unstaged tree without asserting that nothing was committed
- [x] `implement`: Verdict and Conventional Commits message kept; no instruction to commit
- [x] `review-axes`: working-tree mode without the "Never run `git add`, `git commit`, or `git reset`" sentence (the `git add -N .` stays as a step); "since neither commits" neutralized; "Do not commit these markdown edits unless the user asks" removed
- [x] `delegate-tickets`: subagent prompt without the ban list, keeping the context about the index holding earlier tickets' work and the review over the unstaged tree; "never commits" / "Nothing is ever committed" neutralized; orchestrator baseline protocol intact
- [x] Docs pages for `implement` and `review-axes` re-synced per `.agents/writing-docs.md` (FAQs and "It's working if" stop promising no commit)
- [x] `ask-skills` (router) and the `implement` / `ask-skills` guides (en and pt-br) without "never commits" / "não faz `git commit`"
- [x] `fork-divergences.md`: the "`implement` Never commits" and "Refactor step" rows rewritten (upstream instructs commit; the fork neither instructs nor forbids it)
- [x] No em-dashes in the edited prose
