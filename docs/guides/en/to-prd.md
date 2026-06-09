# `/to-prd` — Create PRD from the Conversation

## What it is

A skill that turns the current conversation context into a structured PRD (Product Requirements Document) and publishes it to the project issue tracker.

## What it's for

- When you've already talked about a feature and want to formalise it into a PRD
- To create a requirements document before using `/to-issues`
- When you want a permanent record in the issue tracker of what was decided

## How to invoke

```
/to-prd
```

**Prerequisite**: run `/setup-skills` before using for the first time.

**Important**: the skill *does not interview*. It synthesises what has already been discussed in the conversation. If you haven't discussed the feature in detail yet, use `/grill-me` or `/grill-with-docs` first.

## How it works

**1. Explores the codebase** — reads the current state of the code, using the domain glossary for consistent vocabulary, respecting ADRs in the relevant area.

**2. Identifies test seams** — drafts the points where the feature will be tested. Prefers existing seams. Proposes new seams at the highest possible level. Confirms with you that these seams make sense.

**3. Writes and publishes** — creates the PRD using the template and publishes it as an issue with the `ready-for-agent` label.

### PRD template

**Problem Statement** — the problem the user faces, from the user's perspective.

**Solution** — the solution, from the user's perspective.

**User Stories** — long numbered list in the format:
```
1. As a [actor], I want [feature], so that [benefit]
```
Should be extensive and cover all aspects of the feature.

**Implementation Decisions** — technical decisions made:
- Modules that will be built/modified
- Interfaces that will be modified
- Architectural decisions
- Schema changes
- API contracts

*No file paths or code snippets* (they go stale quickly). Exception: prototype snippets that encode a decision more precisely than prose.

**Testing Decisions** — what makes a good test for this feature, which modules will be tested, similar examples in the codebase.

**Out of Scope** — what is explicitly *not* included in this PRD.

**Further Notes** — additional observations.

## Usage example

```
[After a long conversation about a notification system]

Great, I think we've aligned on everything. Can you create the PRD?

/to-prd
```

The agent will explore the codebase, confirm the test seams with you, and publish the structured PRD as an issue.

## Typical workflow tip

```
1. /grill-with-docs   ← align the design
2. /prototype         ← validate specific questions (optional)
3. /to-prd            ← formalise into a PRD
4. /to-issues         ← break the PRD into implementable tickets
5. /tdd               ← implement each ticket
```
