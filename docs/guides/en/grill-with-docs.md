# `/grill-with-docs` — Grilling with Domain Documentation

## What it is

The engineering-focused version of `/grill-me`. Interviews you about a plan, while simultaneously reading and updating the project documentation (`CONTEXT.md` and ADRs) as decisions are made.

## What it's for

- Before implementing a feature in a project that already has domain documentation
- To build or expand the project's term glossary (`CONTEXT.md`)
- To check whether the plan aligns with already-recorded architectural decisions (ADRs)
- To record new architectural decisions that arise during the conversation
- To ensure new concepts are named consistently with the project's language

## How to invoke

```
/grill-with-docs
```

Describe what you want to do. The skill will explore the codebase and existing documentation before starting to interview.

## How it works

### During the session, the agent:

**Challenges against the glossary** — if you use a term that conflicts with `CONTEXT.md`, it calls it out immediately: *"Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"*

**Sharpens vague language** — when you use ambiguous or overloaded terms, proposes a precise canonical term: *"You're saying 'account' — do you mean Customer or User? They're different things."*

**Tests with concrete scenarios** — invents scenarios to force you to be precise about the edges between concepts.

**Cross-checks with the code** — when you claim how something works, verifies the code agrees. If it finds a contradiction, exposes it: *"Your code cancels entire Orders, but you just said partial cancellation is possible — which is correct?"*

**Updates `CONTEXT.md` inline** — when a term is resolved, updates the glossary immediately, without accumulating.

**Offers ADRs sparingly** — only proposes creating an ADR when the decision is: hard to reverse, surprising without context, and the result of a real trade-off between real alternatives.

## Expected file structure

The agent looks for documentation here:

```
/
├── CONTEXT.md          ← domain glossary
└── docs/
    └── adr/
        ├── 0001-...md  ← architectural decisions
        └── 0002-...md
```

For monorepos with multiple contexts, creates a `CONTEXT-MAP.md` at the root pointing to each module's contexts.

Files are created lazily — only when there's something to write.

## Difference from `/grill-me`

`/grill-me` asks questions without project context.

`/grill-with-docs` reads the existing glossary, ADRs, and code before asking. Updates documentation as the conversation progresses. It's the version for projects with history.

## Usage example

```
I want to add a role-based permissions system to the project. Admin users can do everything, managers can create/edit, viewers can only read.

/grill-with-docs
```

The agent will first read `CONTEXT.md` to see if "Role", "Permission", "User" are already defined, read the ADRs to see if there have been decisions about authentication/authorisation, and then start interviewing — updating the glossary with each new term that gets resolved.

## Why use it

Creates a shared language between you and the agent that pays dividends in every future session: consistently named variables, agent spending fewer tokens on ambiguity, more navigable codebase.
