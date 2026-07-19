---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /review-axes to review the work. Since nothing here is committed, give it **the unstaged working tree** as its fixed point — a ref-based diff would come back empty. Do **not** mark acceptance-criteria checkboxes (`- [ ]` / `- [x]`) in the spec or tickets yourself — `/review-axes` syncs those after the Spec review based on what the code actually did.

Never make a commit. Only generate a commit message for the user to use — not too long, not too short — capped at 300 characters.
