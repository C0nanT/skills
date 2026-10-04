# 03: Refactor step in implement

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** `implement` runs Build → Test → **Refactor** → Review → Report. Refactor runs only when the suite is green after Test (otherwise it is skipped and the Verdict says so), touches only code the run's diff created or changed (working tree vs. index in working-tree mode), changes no behaviour and edits no tests. Before starting it takes a snapshot without committing or touching the index (`git stash create` or copying the diff's files aside; it never stages beyond `git add -N .`, resets, pushes a stash, or commits). After refactoring it reruns the full suite: green keeps the refactor; red restores the working tree exactly to the pre-refactor green state and carries on. Verdict: refactor undone → 🟡; worthwhile refactor seen outside the diff → 🟡 suggesting a prefactor ticket, never applied. `tdd`'s pointer saying refactoring belongs to the review stage now points at `implement`'s Refactor step; the `tdd` loop itself stays as upstream has it.

**Blocked by:** 01 (edits `implement`'s Review step), 02 (edits `tdd`)

**Status:** ready-for-agent

- [ ] `implement` has a Refactor section between Test and Review with precondition, scope, no-behaviour-change rule and a "Done when" line
- [ ] Snapshot and restore rules spelled out, including the forbidden git operations, so `delegate-tickets`' staged earlier work is never disturbed
- [ ] Verdict section covers: refactor skipped (suite red), refactor undone, out-of-diff refactor suggested
- [ ] `tdd` "Refactoring is not part of the loop" rule kept, pointer updated to `implement`'s Refactor step
- [ ] Fork divergence ledger: `implement` row for the Refactor step, noting that upstream moved refactoring out of `tdd` (commit `80e9dcc`), with a grep phrase
- [ ] Docs pages for `implement` and `tdd` re-synced for this behaviour
- [ ] No em-dashes in touched prose; `scripts/validate.sh` passes
