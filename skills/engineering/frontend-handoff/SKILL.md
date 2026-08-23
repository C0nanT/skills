---
name: frontend-handoff
description: Turn a finished backend change into a pasteable handoff for the frontend team, verdict first, must-change, should-change, or nothing.
argument-hint: "Which change? (spec path, branch, PR, or a one-line description)"
disable-model-invocation: true
---

A backend change lands and the frontend dev needs one answer before anything else: **do I have to touch my code?** This skill answers that as a **verdict**, then backs it with contract evidence, payload examples, and a checklist, as a single block they can paste into a ticket or chat.

Read the change before judging it. A verdict inferred from the branch name is the one failure mode that makes this skill worthless.

Write the handoff in the language the user is speaking: this includes section headers, table column headers, and labels like "Yes/No", not just the prose. The template below is written in English only as a structural skeleton; translate every heading and label in it, not just the filled-in content. Keep code, routes, field names, enum values, and HTTP statuses verbatim in the source language.

## Scope

Context only. Frontend work is a separate task: the block describes what the frontend must decide, never patches for it. Never write frontend code.

## Steps

### 1. Pin the change

The handoff needs both halves: the **intent** (what was meant to ship) and the **code** (what actually shipped). Expect a fresh session with no memory of the build, so read both from the repo.

**Intent.** Take whatever the user passed: a feature folder, a spec path, a branch, a PR, commits, changed files, or a prose description. A feature folder is the richest form: read `spec.md` for the whole feature, then every `tickets/NN-*.md`, the ticket bodies say what behaviour was promised and the ticked acceptance criteria say what landed. If nothing was passed, ask **one** question naming those forms, then continue.

**Code.** Pin a fixed point and diff against it, the same way `/review-axes` does:

- committed work → `git diff <fixed-point>...HEAD` (three-dot) plus `git log <fixed-point>..HEAD --oneline`, where the fixed point is what the user named, or the merge-base with the default branch when they named nothing
- uncommitted work → `git add -N .` so new files appear, then plain `git diff`

An empty diff means you pinned the wrong point: say so and ask, rather than writing a handoff from the tickets alone.

Then read the source of truth for the contract itself: route definitions, request validation, response serializers, and the feature tests. A test asserting a response body outranks any prose, including the spec's.

Done when every ticket is accounted for against the diff: each one's shipped behaviour traced to code, and any ticket the diff doesn't cover named in the handoff as out of this drop rather than silently assumed shipped.

### 2. Learn this repo's envelope

Contract judgements are only as good as your model of the response shape. Read `CONTEXT.md` and `CLAUDE.md` for the project's domain language, then the serializers/resources and one passing feature test to fix:

- the standard success envelope (wrapper keys, pagination/meta placement)
- where derived state lives (fields computed from other systems or aggregates, and which sub-objects carry their own status)
- the error envelope and which HTTP codes the frontend is known to branch on
- domain states that look interchangeable but are not (soft-deleted vs finalized vs cancelled)

Done when you can write the envelope from memory and name the derived-state fields the change can move.

### 3. Classify the contract

For each of these, decide changed / unchanged and hold the evidence:

- routes added, renamed, removed
- fields added, renamed, removed, retyped, or newly nullable
- enums or status values added, removed, or redefined
- HTTP codes and error messages the frontend branches on
- behaviour only: same path, same shape, different responses in edge cases

Done when every row of the contract table has a yes/no plus the file or test that proves it.

### 4. Pick the verdict

Exactly one, chosen by the strongest condition that holds:

- **Must change**: breaking contract change, or new capability the frontend has to consume to exist for users.
- **Should change**: contract identical, but current frontend behaviour is now wrong or wasteful: local logic that mirrors backend rules that moved, a **workaround** the backend just made unnecessary, a screen that reads a non-terminal state as terminal, a cache that never revalidates after a mutation that shifts derived state.
- **Nothing required**: contract identical and current frontend behaviour stays correct.

Two guardrails. New behaviour under an unchanged contract caps at **Should change**: if the spec says no contract, schema, or enum change, "Must change" is wrong. And symmetry with the backend is not a reason: a frontend change earns its place only from user-visible behaviour or a contract the frontend reads.

Done when the verdict names the one condition that decided it.

### 5. Fill the block

Fill the template below. Mark a section `N/A` rather than inflating it: an invented route or field is worse than a gap.

### 6. Save the handoff

Save the filled block to `.scratch/<feature-slug>/frontend-handoff.md`, creating the directory if it doesn't exist yet (see `docs/agents/issue-tracker.md` for the `.scratch/` layout). Derive `<feature-slug>` from the feature folder pinned in step 1 when there is one; otherwise slugify the short feature name from the template's title. If a handoff already exists at that path, overwrite it: it describes the same change, not a new one. Save without asking permission first.

### 7. Deliver it

Check the host first: `printenv CLAUDECODE` returns `1` in Claude Code, empty elsewhere.

- **Claude Code**: the file is the copy, so don't reprint it. Answer with the verdict line and the saved path, nothing else.
- **Elsewhere**: verdict line, the whole block, then the saved path in one line.

## Output template

```markdown
## Frontend context: <short feature name>

### Verdict
**<Must change | Should change | Nothing required>**: <one sentence>.

### What the backend changed
- …

### API contract
| Item | Changed? | Detail |
|------|----------|--------|
| Routes | Yes/No | … |
| Envelope / fields | Yes/No | … |
| Enums / statuses | Yes/No | … |
| HTTP codes / known errors | Yes/No | … |

### New behaviour under the same contract
- Before: …
- Now: …

### Frontend impact
| Area | Change needed? | Action |
|------|----------------|--------|
| Types / envelope parsing | … | … |
| Screens & states (e.g. states treated as terminal) | … | … |
| Request payload construction (POST/PUT/PATCH) | … | … |
| Cache, lists, invalidation | … | … |
| 4xx handling | … | … |
| Flows out of scope | No | … |

### Payload / response examples
\`\`\`json
{ … }
\`\`\`

### What the frontend should stop assuming
- …

### Checklist
- [ ] …
```

## Workaround catalogue

Frontend workarounds that a backend change often retires. Each one, if the change removed its cause, is a **Should change**: name the workaround and the evidence it is no longer needed:

- resending untouched history or full collections to dodge a validation error
- stripping fields from an update payload to get past validation
- a screen frozen because a state merely looks terminal
- client-side recomputation of a rule the backend now returns
- a cache that serves stale derived state after a mutation
