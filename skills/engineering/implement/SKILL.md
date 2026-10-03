---
name: implement
description: "Implement a piece of work based on a spec or set of tickets. Use when the user wants a ready spec, ticket, or agreed plan built, or says to implement it."
---

Implement the work described by the user in the spec or tickets, in four steps. Each step is done only when its completion criterion holds.

## Subagent effort

Every subagent spawned during this run, whether you spawn it or a skill you invoke does (`/tdd`, `/review-axes`), runs at **`effort: medium`**, whatever its model. The user's effort level belongs to this session only and never carries over to a spawn.

`high` or above (`high`, `xhigh`, `max`) needs the user's explicit yes **before** the spawn: ask, name the subagent, the model, the effort and why medium is not enough, then wait. No answer is a no. One yes covers only the spawn it was asked for.

Where the host cannot set effort per spawn and the subagent would inherit a `high` or higher level from this session, that inheritance counts as spawning at `high`: ask first, or do the work inline.

## 1. Build

Call the Skill tool with "tdd" where possible, working at pre-agreed seams. Run typechecking regularly and single test files regularly.

Anything you write that outlives the run (docblocks, code comments, READMEs, docs, ADRs) never points into `.scratch/`: that folder is wiped periodically, so the reference would dangle. State the needed fact inline, or cite a permanent file in the repo instead.

Done when: every piece of the spec or tickets is written.

## 2. Test

Run the full test suite once.

Done when: the suite has run and you know its result.

## 3. Review

Invoke the /review-axes skill now, as a real Skill call. Since nothing here is committed, give it **the unstaged working tree** as its fixed point: a ref-based diff would come back empty. Leave acceptance-criteria checkboxes (`- [ ]` / `- [x]`) in the spec or tickets to `/review-axes`, which syncs them after the Spec review based on what the code actually did.

Done when: `/review-axes` has returned its Standards and Spec reports in this run. Steps 1 and 2 passing is the input to this step, never a substitute for it: the Verdict below is built from the review's output, so it cannot be written until the review exists.

## 4. Report

Never make a commit. End with a **Verdict** section, then the commit message.

### Verdict

One line: the emoji, then a short reason. 🟢 is the emoji **alone**, with no text after it.

- 🟢 Everything went as planned: fully implemented, nothing deviated from the spec or tickets, `/review-axes` raised nothing that needs action, no user action needed. Print the emoji and nothing else.
- 🟡 Implemented, but something had to be adjusted mid-flight: planned logic changed, an approach was swapped, a spec detail was interpreted, or `/review-axes` raised findings worth a look. Say what changed and why.
- 🔴 Something did not land, or the user has to act before moving on: a piece was not implemented, `/review-axes` found a spec gap, a decision needs their call, a credential/migration/manual step is required, anything that breaks their "just start the next ticket" flow. Say what it is and what they need to do.

Pick the worst applicable colour: any red condition makes the verdict 🔴 even if the rest went fine.

### Commit message

Generate a Conventional Commits message ≤300 chars for the user: `type(scope): imperative summary` + blank line + short why-body.
