---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues — published as local markdown by default (or to GitHub/GitLab on request) — using tracer-bullet vertical slices.
disable-model-invocation: true
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

## Process

### 1. Choose where to publish

The default is **Local markdown** — files under `.scratch/` in this repo, no remote needed. Don't probe `git remote`; only publish to GitHub or GitLab if the user explicitly asks.

- Ask the user where to publish, with **Local markdown** pre-selected:
  - **Local markdown** (default) — files under `.scratch/<feature-slug>/issues/` in this repo
  - **GitHub** — GitHub issues (`gh` CLI), only if requested
  - **GitLab** — GitLab issues (`glab` CLI), only if requested
- Carry the choice into step 6. For GitHub or GitLab, follow the exact conventions and triage-label mappings in `docs/agents/issue-tracker.md` if it covers that backend; otherwise use the conventions in `<destination-conventions>` below. Run `/setup-matt-pocock-skills` to configure those conventions and a triage-label vocabulary.

### 2. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body and comments.

### 3. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 4. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>

- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Any prefactoring should be done first

</vertical-slice-rules>

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?

Iterate until the user approves the breakdown.

### 6. Publish the issues

For each approved slice, publish a new issue to the destination you chose in step 1. Use the issue body template below. These issues are considered ready for AFK agents, so publish them with the correct triage label unless instructed otherwise.

Publish issues in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field. For **Local markdown**, the identifier is the file's number/slug, and "Blocked by" references the blocking file (e.g. `01-foo.md`).

<destination-conventions>

- **GitHub** — `gh issue create --title "..." --body "..."` (heredoc for the multi-line body). Triage labels via `--label`.
- **GitLab** — `glab issue create --title "..." --description "..."` (heredoc for the multi-line description). Triage labels via `--label`.
- **Local markdown** — write each issue as `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, creating the directory if needed. Record triage state as a `Status:` line near the top of each file instead of a label.

</destination-conventions>

<issue-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

Do NOT close or modify any parent issue.
