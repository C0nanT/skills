---
"mattpocock-skills": patch
---

Reshape the `tdd` skill into reference-only. The red → green → refactor loop is anchored by leading words the model already holds, so the step-by-step Workflow was largely restating the loop and duplicating the horizontal-slicing anti-pattern. Dropped the Workflow and per-cycle checklist; folded their one durable idea — vertical slices / tracer bullets — into the Anti-patterns section and a short Rules-of-the-loop list. Introduced **seam** as the leading word for where tests go, collapsing the old Philosophy "public interfaces" prose and the Planning "confirm interface / behaviors" handshake into one rule: test only at pre-agreed seams, confirmed with the user before any test is written.

Also dropped the refactor stage — TDD is now red → green, not red → green → refactor. Refactoring belongs to the review stage, not the implementation loop, so the refactor rule and `refactoring.md` were removed (its home is the `review` skill).
