---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets, in four steps. Each step is done only when its completion criterion holds.

## 1. Build

Use /tdd where possible, at pre-agreed seams. Run typechecking regularly and single test files regularly.

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
