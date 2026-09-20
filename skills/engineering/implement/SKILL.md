---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /review-axes to review the work. Since nothing here is committed, give it **the unstaged working tree** as its fixed point: a ref-based diff would come back empty. Do **not** mark acceptance-criteria checkboxes (`- [ ]` / `- [x]`) in the spec or tickets yourself, `/review-axes` syncs those after the Spec review based on what the code actually did.

Never make a commit. End with a **Verdict** section, then the commit message.

## Verdict

One line: the emoji, then a short reason. 🟢 is the emoji **alone**, with no text after it.

- 🟢 Everything went as planned: fully implemented, nothing deviated from the spec or tickets, no user action needed. Print the emoji and nothing else.
- 🟡 Implemented, but something had to be adjusted mid-flight: planned logic changed, an approach was swapped, a spec detail was interpreted. Say what changed and why.
- 🔴 Something did not land, or the user has to act before moving on: a piece was not implemented, a decision needs their call, a credential/migration/manual step is required, anything that breaks their "just start the next ticket" flow. Say what it is and what they need to do.

Pick the worst applicable colour: any red condition makes the verdict 🔴 even if the rest went fine.

## Commit message

Generate a Conventional Commits message ≤300 chars for the user: `type(scope): imperative summary` + blank line + short why-body.
