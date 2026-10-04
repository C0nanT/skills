# Skill flow improvements: refactor step, seams handoff, ticket-to-spec link

Status: ready-for-agent

Covers backlog items 1, 2 and 3 in `BACKLOG.md` (same folder). The other items stay in the backlog for later specs.

## Problem Statement

I run features through `grill-me` → `to-spec` → `to-tickets` → `implement` (which calls `tdd` and `review-axes`). Three gaps in how those skills hand work to each other cost me time and quality:

1. **Nobody refactors.** `tdd` keeps refactoring out of its red → green loop and says it belongs to the review stage, but `review-axes` only reports findings and `implement` only writes a Verdict. Code comes out green and is never cleaned up.
2. **I confirm the same seams two or three times.** `to-spec` asks me to confirm the test seams in a separate step (contradicting its own "ask in one batch" rule), and then `tdd` asks again before writing any test, ticket after ticket, even when `implement` runs it on a ticket whose seams were already agreed in the spec.
3. **A local ticket does not point at its spec.** The local ticket template has no origin field, so `review-axes` guesses the spec from the branch or feature name. When the guess misses, the Spec axis is skipped or reviews against the wrong document (finding #10 in the tech-debt ledger).

## Solution

- `implement` gains a **Refactor** step between Test and Review: one pass over the run's own diff, only while the suite is green, with no behaviour change, re-running the suite at the end. If the suite goes red, the refactor is undone entirely and the run carries on with the earlier green code. `tdd` stays as upstream has it.
- Seams are agreed once. `to-spec` folds the seam confirmation into its single batch of questions. `to-tickets` copies the relevant seams into each ticket. `tdd` treats seams listed in the ticket (or, with no ticket, in the spec) as already agreed, and only asks me about a seam that is not on the list.
- Every local ticket names its spec. `review-axes` reads that field before falling back to its heuristic, and `implement` passes the ticket or spec path to `review-axes` explicitly.

## User Stories

1. As a developer running `/implement`, I want a refactor pass after the suite is green, so that the code I commit has been cleaned up and not just made to pass.
2. As a developer, I want the refactor pass limited to code my diff created or changed, so that a ticket's diff does not quietly grow beyond its scope.
3. As a developer, I want worthwhile refactors outside my diff reported in the Verdict as 🟡 with a suggested prefactor ticket, so that I can schedule them without them sneaking into this one.
4. As a developer, I want the refactor undone entirely when it turns the suite red, so that a bad refactor never blocks the run or ships broken code.
5. As a developer, I want an undone refactor reported as 🟡 in the Verdict, so that I know a cleanup was attempted and dropped.
6. As a developer running `/delegate-tickets`, I want the refactor step and its undo to leave the git index untouched, so that earlier tickets' staged work stays isolated from the current ticket.
7. As a developer, I want `review-axes` to review the refactored code, so that its Standards findings reflect what I will actually commit.
8. As a developer running `/to-spec`, I want the seam confirmation asked once inside the single batch of questions, with a proposal attached, so that I answer everything about the spec in one go.
9. As a developer running `/to-spec` with no other open questions, I want just one short question about the seams, so that the spec is not held up by a separate interview step.
10. As a developer, I want each ticket from `/to-tickets` to list the seams it tests, so that a fresh session picking up the ticket has them without reading the whole spec.
11. As a developer running `/implement` on a ticket, I want `tdd` to accept the seams listed in the ticket as agreed, so that I am not asked to confirm them again per ticket.
12. As a developer running `/implement` directly on a spec, I want `tdd` to accept the spec's Testing Decisions seams as agreed, so that the no-ticket path behaves the same way.
13. As a developer, I want `tdd` to still ask me when it needs a seam that is not listed, so that new test boundaries are never invented silently.
14. As a developer using `tdd` standalone, with no ticket or spec, I want it to keep asking for seams as today, so that the standalone flow does not lose its guard.
15. As a developer, I want every local ticket to carry a `Spec:` line pointing at its spec, so that tools and people can find the source of truth from the ticket.
16. As a developer, I want `review-axes` to find the spec through the ticket's `Spec:` line before any guessing, so that the Spec axis reviews against the right document.
17. As a developer, I want `review-axes` to keep its remote-tracker `Parent` lookup and its current heuristic as fallbacks, so that tickets on GitHub/GitLab and older tickets still work.
18. As a developer, I want `implement` to hand `review-axes` the ticket or spec path explicitly, so that the review never depends on search at all inside the pipeline.
19. As a maintainer of this fork, I want every new divergence from upstream recorded in the fork divergence ledger, so that the next upstream sync does not silently revert it.

## Implementation Decisions

**`implement`: new Refactor step**

- Step order becomes Build → Test → **Refactor** → Review → Report.
- Precondition: the full suite is green after Test. If it is not green, skip the Refactor step (the Test failure is handled as today) and say so in the Verdict.
- Scope: only code the run's diff created or changed. In working-tree mode that is the working tree vs. the index, so under `delegate-tickets` it is exactly the current ticket.
- Rule: no behaviour change. Tests are not edited to make a refactor pass.
- Before refactoring, take a snapshot without committing and without touching the index. Allowed: `git stash create` (records the state, changes no ref, index or working tree) or copying the diff's files aside. Not allowed: `git add` (beyond the `git add -N .` that `review-axes` already does), `git reset`, `git stash push`, `git commit`.
- After refactoring, run the full suite. Green: keep the refactor. Red: restore the snapshot so the working tree is exactly the pre-refactor green state, then continue to Review.
- Verdict mapping: refactor kept, nothing else → no effect on colour. Refactor undone → 🟡 with a one-line reason. Worthwhile refactor seen outside the diff → 🟡 suggesting a prefactor ticket, never applied.
- Done when: the refactor is either kept with a green suite, or undone back to the green snapshot.

**`implement`: passes the spec source to `review-axes`**

- The Review step passes the ticket path (or the spec path when there is no ticket) alongside "the unstaged working tree", so `review-axes` never has to search.

**`to-spec`: seams in the single batch**

- The separate "check with the user that these seams match" step is folded into the existing one-batch question rule: the seam proposal is one of the batch's questions, carrying the proposed seams as the best guess.
- When nothing else clears the asking bar, ask one short question about the seams only, then write the spec.
- The agreed seams are written into the spec's **Testing Decisions**, in a form `to-tickets` and `tdd` can pick up (one seam per bullet).

**`to-tickets`: `Spec:` and `Seams:` fields**

- The local ticket template gains a `**Spec:**` line with the spec's path relative to the ticket file (with the current layout, `../SPEC.md`), and a `**Seams:**` line listing the seams from the spec's Testing Decisions that this ticket exercises.
- The remote-tracker issue template gains the same `Seams` content; its existing `Parent` section already plays the role of `Spec:`.
- A ticket that tests no seam (for example a pure config change) says so explicitly rather than leaving the field out.

**`tdd`: agreed seams from ticket or spec**

- Source order for agreed seams: the ticket's `Seams:` line, else the spec's Testing Decisions, else none.
- When a source exists, its seams count as confirmed: no question before writing tests at them. Asking is only for a seam not on the list.
- With no source (standalone use), behaviour is unchanged: write the seams down and confirm them with the user.
- Refactoring stays out of the `tdd` loop, as upstream has it. The pointer that says refactoring belongs to the review stage is updated to point at `implement`'s Refactor step.

**`review-axes`: spec search order**

- New order: (1) a path passed as an argument; (2) the `Spec:` line of the ticket being reviewed (the passed ticket, or a ticket file matched by the existing search); (3) the `Parent` section on a remote tracker; (4) the current heuristic (spec file under `.scratch/`, `docs/` or `specs/` matching the branch or feature, then issue refs in commit messages); (5) ask the user.
- When the ticket is passed, the checkbox sync in step 6 keeps targeting the ticket file, not the spec it points to.

**Repo bookkeeping (same change)**

- Fork divergence ledger: new rows for `implement` (Refactor step), `to-spec` (seams in the single batch), `to-tickets` (`Spec:` and `Seams:` fields), `tdd` (agreed seams from ticket or spec); update the existing `review-axes` "local-markdown first" row to the new search order. Each row carries the grep phrase that would show upstream's version came back.
- Docs pages for `implement`, `tdd`, `to-spec`, `to-tickets` and `review-axes` re-synced per the docs-writing guide.
- `ask-skills` re-read and updated if its description of the flow mentions seam confirmation, refactoring, or how the review finds the spec.
- `delegate-tickets` re-read: its brief to sub-agents about invoking `review-axes` stays consistent with `implement` passing the ticket path.
- Tech-debt ledger: finding #10 marked resolved.
- `BACKLOG.md`: items 1, 2 and 3 marked done.
- No em-dashes in any prose touched.

## Testing Decisions

- No automated tests for this change: every edit is skill prose (markdown), and a text-grep check on templates would be tautological. Protection against upstream reverting the change comes from the grep phrases in the fork divergence ledger.
- The repo's existing CI check (`scripts/validate.sh`) runs as usual and must stay green; nothing is added to it.

## Out of Scope

- Backlog items 4 to 13 (review fix pass, persisting grilling decisions, round size, difficulty tiers, requirement IDs, test-failure handling, blocker checks, `tdd` red-for-the-right-reason and bug flow, `review-axes` model choice, `to-spec` frontmatter blank line). They stay in `BACKLOG.md`.
- Putting refactoring back inside the `tdd` loop.
- Any change to how `review-axes` itself reports findings or picks sub-agent models.
- Migrating existing tickets to add `Spec:` / `Seams:` lines; the `review-axes` fallbacks cover them.
- Changes to the plugin manifests or the top-level README (no skill is added, removed or renamed).

## Further Notes

- Origin: the refactor-out-of-the-loop rule came from upstream (commit `80e9dcc`, where upstream points at its `code-review` skill). This spec deliberately keeps `tdd` close to upstream and puts the divergence in `implement`, so the sync cost lands in one place.
- Item 4 (review fix pass) will later add another step after Review; the Refactor step here comes before Review on purpose, so `review-axes` judges the cleaned code.
