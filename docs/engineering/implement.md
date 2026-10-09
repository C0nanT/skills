## What it does

`implement` builds work that has already been decided. You point it at a [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket), a [spec](https://www.aihero.dev/ai-coding-dictionary/spec), or the plan you just agreed in the conversation, and it writes the code, drives [tdd](https://aihero.dev/skills-tdd) at the seams, typechecks as it goes, refactors its own diff once the suite is green, runs [review-axes](./review-axes.md) at the end, commits the work to the current branch, and hands you a one-line verdict.

It never reopens the plan. There is no interview, no clarifying round, no proposal of a different approach. Whatever was settled upstream is the input, and the skill's whole job is to turn that into a ready-to-commit diff plus a message. That is what separates it from typing "build this" at a fresh [agent](https://www.aihero.dev/ai-coding-dictionary/agent), which will happily redesign the work while it builds it.

## When to reach for it

Type `/implement`, or let the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) reach for it when a spec or ticket is ready to build. It is model-invoked in both Claude Code and Codex, so other skills such as `delegate-tickets` can call it too. Wherever [ask-skills](./ask-skills.md) or [to-tickets](https://aihero.dev/skills-to-tickets) says "then `/implement` per ticket", that is still the step to take per ticket.

Where the work currently lives decides whether this is the right skill:

| The work is… | Reach for |
| --- | --- |
| A ticket on the tracker | `/implement #42`, one ticket per [session](https://www.aihero.dev/ai-coding-dictionary/session), [clearing](https://www.aihero.dev/ai-coding-dictionary/clearing) context between tickets |
| A spec, not yet split up, and the build spans sessions | [to-tickets](https://aihero.dev/skills-to-tickets) first, then `/implement` per ticket |
| A spec, and the build is small | `/implement` directly against the spec |
| Only in the conversation you just had, and it's still small | `/implement` right there, in the same window |
| Not written down anywhere yet | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), or [grill-me](https://aihero.dev/skills-grill-me) if there's no codebase |
| One concrete behaviour you want test-first, with no spec | [tdd](https://aihero.dev/skills-tdd) directly |
| Already built, and you want it checked | [review-axes](./review-axes.md) directly |

The same-session case is worth naming because the skill's own first line doesn't cover it. `SKILL.md` says "the spec or tickets", which pushes the [model](https://www.aihero.dev/ai-coding-dictionary/model) to look for a file that doesn't exist. If the plan lives only in the thread, say so when you invoke it.

## Prerequisites

`implement` commits to the branch you are on. Check you are on the branch you want the work on before you start, so the commit lands where you intend.

If the tickets came from [to-tickets](https://aihero.dev/skills-to-tickets), the tracker they live on was configured by [setup-skills](./setup-skills.md). `review-axes` reads the same configuration to find the originating spec at close-out. Local tickets carry a `Spec:` line, and `implement` passes the ticket path along, so inside this chain the review does not depend on search.

## What one run does

A run is seven beats, in order:

1. Read the ticket or spec and work out the seams.
2. Drive [tdd](https://aihero.dev/skills-tdd) at the pre-agreed seams, one red-green slice at a time.
3. Typecheck often, run single test files as it goes.
4. Run the full test suite once, at the end.
5. Refactor the run's own diff, only if the suite is green: no behaviour change, no test edits, snapshot first (with `git stash create`, which leaves the index alone), rerun the suite, and restore the snapshot if it went red.
6. Run [review-axes](./review-axes.md) against the unstaged working tree, passing it the ticket path (or the spec path when there is no ticket) so it never has to search for the spec and ticks the right checkboxes. This is a gate, not a suggestion: the verdict is built from its Standards and Spec reports, so a run that skipped it has nothing to base the verdict on.
7. Commit the work to the current branch.
8. Give a verdict (🟢 / 🟡 / 🔴).

One run covers one ticket. The tickets [to-tickets](https://aihero.dev/skills-to-tickets) produces are tracer-bullet vertical slices sized to fit a single fresh [context window](https://www.aihero.dev/ai-coding-dictionary/context-window), so the intended rhythm is: clear context, implement one ticket, you commit from the message it wrote, clear again. Each ticket is self-contained, which is what makes the previous ticket's context disposable.

## Pre-agreed seams

The skill's central idea is the **seam**, the public boundary you observe behaviour at without reaching inside. Tests live at seams. When the seam is agreed before any code exists, the tests last, and you can rewrite the implementation underneath without changing them.

The "pre-agreed" part matters, and it is also the skill's weakest point. Nothing inside `implement` agrees the seams. `tdd` is the skill that asks, and it refuses to write a test at an unconfirmed seam. So in practice the agreement happens either upstream in the spec, or in the first exchange of the run. If it happens nowhere, the run becomes "just write the code" and nothing warns you. Naming the seams in the spec is what stops that.

## Common questions

**It finished, but my ticket is still open and the acceptance criteria are still unchecked.**

Half expected. `implement` has no completion step: it ends at a commit *message* (you still commit) and never closes the work item, on GitHub Issues or on the local markdown tracker, so it is not a tracker integration problem. It also does not act on the findings `review-axes` produced. The checkboxes are different here, this fork moved that job into `review-axes`, which after its Spec review flips the `- [ ]` boxes on a **local markdown** spec or ticket to match what the code actually did, and advances `Status:` to `ready-for-human` once they are all checked. On a remote tracker, and for closing the ticket itself, reconcile it yourself. This bites hardest on a dependency chain, because `to-tickets` defines the frontier as tickets whose blockers are all closed. If nothing gets closed, nothing ever becomes visibly unblocked.

**What do the coloured circles at the end mean?**

That is the verdict, a fork addition that ends the run. 🟢 is printed bare, with no text after it: the run went exactly as planned and you can move to the next ticket. 🟡 means it is implemented but something was adjusted mid-flight, a planned piece of logic changed or a spec detail was interpreted, and the reason is on the same line. 🔴 means either something did not land or you have to act before moving on, for example a decision only you can make, a migration, or a credential. The worst applicable colour wins, so one red condition makes the whole run 🔴. It is a signal to read, not a gate: a 🔴 run is still committed, so read it before you build on top.

**What does the refactor step do, and what if it breaks something?**

After the full suite is green, `implement` makes one cleanup pass over the code its own diff created or changed, never beyond it. It changes no behaviour and edits no tests. Before starting it snapshots the working tree with `git stash create` (or copies the files aside), which records the state without changing any ref, the index or the working tree. It then reruns the full suite: green keeps the refactor, red restores the snapshot exactly and the run carries on. The verdict is 🟡 when the refactor was skipped (suite red), undone, or when a worthwhile refactor was spotted outside the diff, in which case it suggests a prefactor ticket and never applies it.

**Can I point it at all my tickets at once, or run several in parallel?**

Not with `/implement`: one invocation, one ticket. For a whole spec in one run, use [implement-spec](./implement-spec.md), which gives each ticket on the ready frontier to a [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) in its own worktree, then merges the results onto one integration branch. Running several `/implement` sessions side by side in one checkout is worse than unsupported. One field report describes a `git commit --amend` in one session landing on another session's commit, a stash vanishing from `refs/stash`, and commits landing on the wrong branch, all in a single afternoon across three issues. The sessions share one working directory, one index, and one HEAD. Users work around this with git worktrees, but `refs/stash` is shared across worktrees too, so worktrees alone do not fix the stash case.

**Can it open a pull request instead of committing?**

Not built in. It commits straight to the current branch. Several people find this too eager, because the code lands before they can verify it works. There is no configuration flag and no PR mode. Override it in the invocation ("commit to a branch and open a PR") or in your local copy of the skill. When the agent does write the PR, [pr](./pr.md) shapes its body.

**`review-axes` says it cannot see my changes.**

Given a ref, `review-axes` reviews `git diff <fixed-point>...HEAD`, which excludes staged and working-tree changes, so upstream, where `implement` runs the review before committing, there is nothing in that diff to review unless an interim commit already exists. This fork fixes it from both ends: `review-axes` has a working-tree mode, and `implement` hands it **the unstaged working tree** as the fixed point instead of a ref. If you see an empty review, check that the run really passed working-tree mode; otherwise commit first and review against the point you branched from.

Separately, some people deliberately do not want the review inside the run at all, because an agent reviewing the code it just wrote is biased toward its own solution. Running [review-axes](./review-axes.md) in a fresh session against a fixed point is a legitimate alternative, and is the same reason that skill runs its two axes in separate sub-agents.

**One ticket burned 150k tokens. Am I using it wrong?**

Probably not. The ticket is more likely too big. A run does codebase exploration, a red-green loop per seam, a full suite, and a review, so a non-trivial ticket exceeding 100k [tokens](https://www.aihero.dev/ai-coding-dictionary/token) is normal rather than a sign something broke. The fix is upstream. Right-size the tickets in [to-tickets](https://aihero.dev/skills-to-tickets) so each fits one fresh window. If a single ticket keeps going over, split it rather than raising the [effort](https://www.aihero.dev/ai-coding-dictionary/effort) level.

**Why did it stop and ask before spawning a subagent?**

This fork caps subagent effort. Any subagent spawned during a run, including the ones [review-axes](./review-axes.md) spawns for its two axes, runs at `effort: medium`, whatever model it uses and whatever effort you picked for your own session. Your session's effort stays yours: choosing `high` for the main model does not hand `high` to every spawn. A subagent at `high`, `xhigh` or `max` needs your explicit yes first, so the agent asks, names the model and effort, and says why medium is not enough. Silence is a no, and one yes covers only that one spawn. When nobody is there to answer (the run is a subagent, for example one started by `/delegate-tickets`), the run stops and reports the question as a blocker instead of doing the work inline.

**Why don't the comments and docs it writes link to the ticket or spec?**

On purpose. Tickets and specs live under `.scratch/`, which gets wiped from time to time, so a docblock or README that says "see `.scratch/…`" turns into a dead link. This fork tells the run to state the needed fact inline, or cite a permanent file in the repo, instead.

**`/implement #2` in a fresh session worked on something completely unrelated.**

The agent resolved `#2` against another numbered list in context, such as a todo file or checklist, rather than the configured tracker. `implement` now fetches a passed reference from the issue tracker and states its title before starting, and asks when the reference is ambiguous. Check that title matches the ticket you meant; passing the issue URL or `owner/repo#2` removes the ambiguity entirely.

## It's working if

- The session opens by reading the ticket or spec and restating what it will build, rather than asking you what to build.
- You can see an actual `/tdd` invocation in the trace, not just tests appearing in the diff.
- Typechecks and single test files run repeatedly during the run, and the full suite runs once near the end (and once more after a refactor).
- The run ends with a commit on the current branch and a verdict line.
- The verdict colour matches what actually happened: a bare 🟢 when nothing deviated, 🟡 with the adjustment named, 🔴 with the thing you have to do spelled out.
- The diff is one ticket's worth of change: a vertical slice through every layer, not several tickets swept together.

## Where it fits

`implement` is the build step of the main chain:

```txt
grill-with-docs → to-spec → to-tickets → implement → review-axes → retro
```

Its neighbours are [to-tickets](https://aihero.dev/skills-to-tickets), which produces the tickets it consumes and declares the blocking edges that decide their order; [tdd](https://aihero.dev/skills-tdd), which it drives internally at each seam; and [review-axes](./review-axes.md), which it runs before committing. It sits downstream of the planning skills and trusts them. It does not re-validate the shape of what it was handed, so a badly-structured map or a horizontally-layered ticket gets built as written.

That trust is why [wayfinder](https://aihero.dev/skills-wayfinder) merges onto the chain at [to-spec](https://aihero.dev/skills-to-spec) rather than looping its map straight into `implement`. Go straight to `implement` from a map only when the effort turned out small.

[ask-skills](./ask-skills.md) is the router over the whole set when you are not sure which flow you are in.
