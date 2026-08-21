## What it does

`sync-upstream` merges the upstream repo this project was forked from, then resolves the fallout in favour of the fork. It treats the fork's deliberate differences (renamed skills, changed behaviour, dropped files) as a written **ledger**, and defends every entry in it against the merge.

The conflicts git shows you are the easy half. The half this skill exists for is the other one: a file that merged **cleanly** because only upstream touched that line, quietly restoring a name you renamed or a paragraph you rewrote. Nothing marks it, `git status` looks finished, and the divergence is gone. So after resolving the marked conflicts, it counts every upstream-side name across the tree, before and after, and fixes whatever the merge took back.

## When to reach for it

You invoke this by typing `/sync-upstream`: the agent won't reach for it on its own. Reach for it whenever you pull upstream changes into a fork you have modified, either before the merge (it runs it) or after (it picks up one already in progress).

| Your situation | Reach for |
| --- | --- |
| A fork needs upstream's changes, and you have local divergences worth keeping | `sync-upstream` |
| An ordinary merge or rebase conflict, no fork relationship involved | [resolving-merge-conflicts](https://aihero.dev/skills-resolving-merge-conflicts) |
| The merge is done and you want the result judged as a change | [review-axes](./review-axes.md) |

## Prerequisites

An `upstream` remote, and a **ledger**: a file recording how this fork differs from it. This repo keeps one at `.agents/fork-divergences.md`. Without a ledger the skill still resolves the marked conflicts, but the silent-clobber sweep has nothing to search for, so it writes one at the end from what it learned and says that it did.

If the repo has a sync script, the skill prefers it: a script is where the list of upstream paths the fork strips already lives, and it knows things the ledger doesn't.

## The two halves

**Marked conflicts.** The resolution is never "ours or theirs". The skill asks what upstream actually changed (`git diff <merge-base> upstream/main -- <path>`) and resolves by kind: cosmetic reword or a rename of something you renamed goes to the fork; genuinely new upstream substance is taken and then rewritten into the fork's names and facts; a fork behaviour upstream doesn't have always wins. `git checkout --ours` is banned outright, because it also discards the parts of upstream's delta that merged cleanly into the same file.

**Silent clobbers.** For each ledger entry, the count of upstream's name before the merge versus after. A file whose count went up took it back. This is the mechanical version of a check nobody does by hand, and it is where the renamed-skill references, the stale "it can't do that" FAQ answers, and the manifest pointing at a path upstream deleted all turn up.

One trap gets its own rule: a doc that describes fork behaviour has to be re-read against the fork's `SKILL.md`, not just renamed. Upstream's prose is written about upstream's behaviour, so an answer saying a thing is impossible is a confident lie in a fork where that thing works. Renaming it leaves the lie in place and makes it look reviewed.

## Common questions

**Why does it stop without committing?**

Because a fork sync is a judgement call end to end, and the diff is the only place you can audit it. The skill leaves the merge open, reports what it resolved and which way each went, and waits. Ask it to finish and it will.

**Upstream promoted a new skill. Does it just take it?**

No: it lists it and asks. Whether the fork wants a new skill is a decision about the fork, not a conflict to resolve, and silently shipping one is how a curated set stops being curated. The same goes the other way: a skill upstream deleted stays until you say otherwise.

**Do I still need `/resolving-merge-conflicts`?**

For any conflict that isn't a fork sync, yes: that skill resolves hunk by hunk by tracing each side's intent, with no ledger and no fork to defend. `/sync-upstream` is the narrower tool: one upstream, one recurring merge, a written list of things that must survive it.

## It's working if

- It reads the ledger before it opens a single conflicted file, and says so.
- Its report separates conflicts it resolved from divergences it caught that were never marked as conflicts.
- The tree has no `<<<<<<<` left, and no file gained a mention of an upstream name the ledger says this fork renamed.
- Whatever validation the repo documents is run, not assumed.
- The ledger ends the session longer than it started, or the skill says explicitly that nothing new was learned.
- The merge is still open when it hands back.

## Where it fits

`sync-upstream` is **periodic maintenance** on the repo itself: reach for it each time upstream moves, and nowhere else. It sits off every build flow: nothing feeds it, and what it produces is a merge you review like any other change.

Its one neighbour is [resolving-merge-conflicts](https://aihero.dev/skills-resolving-merge-conflicts), the general-purpose version of its first half: reach for that one when there is no fork relationship and no ledger to defend. [ask-skills](./ask-skills.md) routes across the whole set when you are unsure which skill the situation wants.
