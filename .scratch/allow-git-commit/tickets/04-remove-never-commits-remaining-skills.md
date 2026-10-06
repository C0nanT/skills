# 04: Remove "never commits" from archive-feature, review-mr, sync-upstream

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** `../SPEC.md`

**What to build:** `/archive-feature`, `/review-mr` and the dev-only `sync-upstream` skill stop forbidding commit, without gaining an instruction to commit. `review-mr` keeps the other state-protection bans (`stash`, `checkout`, `reset`). The READMEs and tracker docs that repeat "never commits" follow suit.

**Seams:**
- None (skill prose; verified by the criteria below)

**Blocked by:** None (can start immediately)

Status: ready-for-agent

- [ ] `archive-feature`: intro and report step without "never commits" / "Never commit."; report unchanged
- [ ] `review-mr`: only `commit` removed from the list of commands never run (skill and docs page)
- [ ] `sync-upstream`: "**Do not commit.**" removed; report with the merge open for review kept
- [ ] One-liners for `implement` and `archive-feature` in the top-level `README.md` and in the `engineering/` bucket README without "Never commits"
- [ ] The repo's `docs/agents/issue-tracker.md` and the `issue-tracker-local.md` template in `setup-skills` without "never commits"
- [ ] `archive-feature` docs page re-synced per `.agents/writing-docs.md`; `setup-skills` guide (pt-br) section on archiving without the restriction
- [ ] `fork-divergences.md`: `archive-feature` line updated if it mentions commit
- [ ] No text tells the agent to commit; no em-dashes in the edited prose
