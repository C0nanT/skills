---
name: to-prd
description: Turn the current conversation into a PRD and publish it as local markdown by default (or GitHub/GitLab on request) — no interview, just synthesis of what you've already discussed.
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know.

## Process

1. **Choose where to publish.** The default is **Local markdown** — a file under `.scratch/` in this repo, no remote needed. Don't probe `git remote`; only publish to GitHub or GitLab if the user explicitly asks.

   - Ask the user where to publish, with **Local markdown** pre-selected:
     - **Local markdown** (default) — a file at `.scratch/<feature-slug>/PRD.md` in this repo
     - **GitHub** — a GitHub issue (`gh` CLI), only if requested
     - **GitLab** — a GitLab issue (`glab` CLI), only if requested
   - Carry the choice into step 4. For GitHub or GitLab, follow the exact conventions and triage-label mappings in `docs/agents/issue-tracker.md` if it covers that backend; otherwise use the conventions in `<destination-conventions>` below. Run `/setup-skills` to configure those conventions and a triage-label vocabulary.

2. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the PRD, and respect any ADRs in the area you're touching.

3. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

4. Write the PRD using the template below, then publish it to the destination you chose in step 1. Apply the `ready-for-agent` triage label — no need for additional triage. (For **Local markdown**, "applying a label" means writing a `Status: ready-for-agent` line near the top of the file instead.)

<destination-conventions>

- **GitHub** — `gh issue create --title "..." --body "..."` (heredoc for the multi-line body). Triage labels via `--label`.
- **GitLab** — `glab issue create --title "..." --description "..."` (heredoc for the multi-line description). Triage labels via `--label`.
- **Local markdown** — write `.scratch/<feature-slug>/PRD.md`, creating the directory if needed. Record triage state as a `Status:` line near the top of the file instead of a label.

</destination-conventions>

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
