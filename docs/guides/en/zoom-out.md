# `/zoom-out` — High-Level Context View

## What it is

A simple, direct skill that tells the agent to step up one abstraction level and give a map of all the relevant modules and callers in an area of code you don't know well.

## What it's for

- When you're looking at code you don't know and need to understand where it fits in the larger system
- When you want to know who calls what before changing something
- When you're lost in an area of the codebase and need orientation
- As a starting point before using `/diagnose` or `/tdd` in a new area

## How to invoke

```
/zoom-out
```

No additional arguments needed. The skill tells the agent exactly what to do.

## How it works

It's a direct instruction to the agent:

> "I don't know this area of the code well. Step up one abstraction level. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary."

The agent then:
1. Reads `CONTEXT.md` to use the correct domain language
2. Maps the modules involved in the area in question
3. Shows who calls what, the dependencies, the general flow
4. Uses domain terms (not internal file names or generic technical jargon)

## Usage example

```
I need to change the order cancellation process but I don't know how the code works here.

/zoom-out
```

The agent will respond with something like: "The cancellation flow involves 3 modules: OrderService (manages order state), RefundProcessor (issues the refund), and NotificationQueue (notifies the customer). The OrderService calls the RefundProcessor which in turn queues a notification..."

## Note

This skill has `disable-model-invocation: true` — meaning it's an instruction passed directly to the agent's context, with no additional processing logic. It is intentionally simple: one sentence that reorients the agent toward the high-level view.
