---
name: implement
description: "Implement a piece of work based on a spec or set of tickets. Use when the user wants a ready spec, ticket, or agreed plan built, or says to implement it."
---

Implement the work described by the user in the spec or tickets, in six steps. Each step is done only when its completion criterion holds.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

## Subagent effort

Every subagent spawned during this run, whether you spawn it or a skill you invoke does (`/tdd`, `/review-axes`), runs at **`effort: medium`**, whatever its model. The user's effort level belongs to this session only and never carries over to a spawn.

`high` or above (`high`, `xhigh`, `max`) needs the user's explicit yes **before** the spawn: ask, name the subagent, the model, the effort and why medium is not enough, then wait. No answer is a no. One yes covers only the spawn it was asked for.

Where the host cannot set effort per spawn and the subagent would inherit a `high` or higher level from this session, that inheritance counts as spawning at `high`: it needs the same yes first.

If no human can answer (you run as a subagent, unattended, or the brief says nobody is around), stop and report the question as a blocker. Never fall back to doing the work inline. In an interactive session, keep asking and waiting for the yes as above. The same rule covers every other question this run would put to the user, such as where the spec is: unattended, it is a blocker, never a guess.

## 1. Build

Call the Skill tool with "tdd" where possible, working at pre-agreed seams. Run typechecking regularly and single test files regularly.

Anything you write that outlives the run (docblocks, code comments, READMEs, docs, ADRs) never points into `.scratch/`: that folder is wiped periodically, so the reference would dangle. State the needed fact inline, or cite a permanent file in the repo instead.

Done when: every piece of the spec or tickets is written.

## 2. Test

Run the full test suite once.

Done when: the suite has run and you know its result.

## 3. Refactor

One cleanup pass over the code this run wrote, only while the suite is green.

- **Precondition:** the full suite was green after Test. If it was not, skip this step and say so in the Verdict.
- **Scope:** only code the run's diff created or changed (the uncommitted working tree, so under `/delegate-tickets` exactly the current ticket). A worthwhile refactor you see outside the diff is never applied: note it for the Verdict.
- **Rule:** no behaviour change. Never edit a test to make a refactor pass.
- **Snapshot first.** Use `git stash create` (records the state, changes no ref, index or working tree) or copy the diff's files aside.
- **After refactoring, run the full suite.** Green: keep the refactor. Red: restore the snapshot so the working tree is exactly the pre-refactor green state (for a `git stash create` snapshot, `git restore --source=<snapshot> --worktree -- <files>`, which leaves the index alone; also delete any file the refactor created and recreate any it deleted, since a snapshot does not cover them), then carry on to Review.

Done when: the refactor is either kept with a green suite, or undone back to the green snapshot, or skipped because the suite was red.

## 4. Review

Invoke the /review-axes skill now, as a real Skill call. Give it **the unstaged working tree** as its fixed point: the changes are not in any commit yet, so a ref-based diff would come back empty. Alongside it, pass the path of the ticket you were given, or the spec path when there is no ticket, as the spec argument, so it never has to search for the spec and syncs the right checkboxes. Leave acceptance-criteria checkboxes (`- [ ]` / `- [x]`) in the spec or tickets to `/review-axes`, which syncs them after the Spec review based on what the code actually did.

Done when: `/review-axes` has returned its Standards and Spec reports in this run. Steps 1 to 3 passing is the input to this step, never a substitute for it: the Verdict below is built from the review's output, so it cannot be written until the review exists.

## 5. Commit

Commit your work to the current branch.

Done when: the run's changes are in a commit on the current branch.

## 6. Report

End with a **Verdict** section.

### Verdict

One line: the emoji, then a short reason. 🟢 is the emoji **alone**, with no text after it.

- 🟢 Everything went as planned: fully implemented, nothing deviated from the spec or tickets, `/review-axes` raised nothing that needs action, no user action needed. Print the emoji and nothing else.
- 🟡 Implemented, but something had to be adjusted mid-flight: planned logic changed, an approach was swapped, a spec detail was interpreted, or `/review-axes` raised findings worth a look. Also 🟡: the refactor was undone because the suite went red after it (one-line reason), or a worthwhile refactor was seen outside the diff (suggest a prefactor ticket, never apply it). A refactor that was kept has no effect on the colour. A refactor skipped because the suite was red is stated in the Verdict, and the red suite itself sets the colour as it does today. Say what changed and why.
- 🔴 Something did not land, or the user has to act before moving on: a piece was not implemented, `/review-axes` found a spec gap, a decision needs their call, a credential/migration/manual step is required, anything that breaks their "just start the next ticket" flow. Say what it is and what they need to do.

Pick the worst applicable colour: any red condition makes the verdict 🔴 even if the rest went fine.
