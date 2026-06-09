# `/grill-me` — Relentless Interview About Your Plan

## What it is

A productivity skill that makes the agent interview you intensely about a plan or design, resolving each branch of the decision tree one at a time.

## What it's for

- Before starting to implement a new feature
- When you have an idea but it's still fuzzy
- When you want to stress-test a design before committing to it
- When you need to think out loud with someone who will ask hard questions
- To align with the agent before it writes code

## How to invoke

```
/grill-me
```

Describe what you want to build, or bring the conversation you've already had. The skill will start interviewing you.

## How it works

The agent takes the role of a relentless interviewer. For each aspect of the plan:

1. **Asks one question at a time** — doesn't dump 10 questions at once. Waits for your answer before continuing.

2. **Proposes a recommended answer** — for each question, the agent already says what *it* thinks is the best answer. You can agree, disagree, or refine.

3. **Explores the codebase when needed** — if a question can be answered by reading existing code, the agent does that instead of asking.

4. **Descends the decision tree** — resolves dependencies between decisions. Only asks about one thing after the previous is resolved.

The process continues until *all* branches of the decision tree are resolved and there is complete shared understanding.

## Difference from `/grill-with-docs`

`/grill-me` is generic — works for any plan, inside or outside code.

`/grill-with-docs` is the engineering version: does everything `/grill-me` does, but also reads the project's `CONTEXT.md` (domain glossary), checks ADRs, updates the glossary inline as terms are resolved, and offers to create ADRs for important architectural decisions.

## Usage example

```
I want to create a real-time notification system for the app. Users should receive alerts when someone comments on their task.

/grill-me
```

The agent will start asking questions: "Which transport: WebSockets, SSE, or polling? My recommendation is SSE because..." — and so on until covering transport, authentication, persistence, reading notifications, etc.

## Why use it

The most common problem with AI agents is misalignment: the agent builds something different from what you wanted. A grilling session before implementing is the antidote. Costs 10 minutes and saves hours of rework.
