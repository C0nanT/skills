# 04: Wire `archive-feature` into the repo

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** `archive-feature` is findable and installable like every promoted skill, the router ends the daily flow with it, the tracker docs point finished features to the archive, and the next upstream sync keeps it.

**Seams:**
- None (wiring and docs, verified by `claude plugin validate . --strict` and reading the files)

**Blocked by:** 03 (the docs page and router describe the final behaviour)

Status: ready-for-agent

- [ ] Entry under **User-invoked** in the top-level `README.md` and in the `engineering/` bucket `README.md`
- [ ] Entry in `.claude-plugin/plugin.json`'s `skills` array; `claude plugin validate . --strict` passes
- [ ] Docs page `docs/engineering/archive-feature.md` with the four sections from `.agents/writing-docs.md`
- [ ] `ask-skills` re-read and updated so the flow ends grill-me → to-spec → to-tickets → implement → archive-feature
- [ ] This repo's `docs/agents/issue-tracker.md` and the `setup-skills` local tracker template point finished features to `docs/archive/<feature-slug>/` via `archive-feature`
- [ ] The `setup-skills` guide's "Optional: archive finished features" section mentions `archive-feature` (English and pt-br guides)
- [ ] Row in `.agents/fork-divergences.md` for the new skill, with a grep phrase
- [ ] No em-dashes
