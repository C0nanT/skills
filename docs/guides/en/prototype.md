# `/prototype` — Throwaway Prototype

## What it is

A skill that builds throwaway prototypes to validate a design before committing to the real implementation. The prototype answers a specific question — and then gets deleted.

## What it's for

- When you're not sure if a data model or state machine will work
- When you want to see what a UI will look like before implementing for real
- When you have design options and want to explore variations before choosing
- When you want to "play" with an idea before turning it into production code
- Any situation where "let me try it before deciding" makes sense

## How to invoke

```
/prototype
```

Describe what you want to explore. The skill will identify which type of prototype makes sense.

## How it works

The skill chooses between two branches:

### Branch 1: Logic/State — `LOGIC.md`

**Question being answered**: "Does this data model / state machine make sense?"

Builds a **minimalist, interactive terminal app** that lets you navigate the state machine manually, testing edge cases that are hard to reason about on paper.

Characteristics:
- Runs with one command (e.g. `pnpm prototype`)
- No persistence — state lives in memory
- Displays the full state after each action
- Throwaway from day one

### Branch 2: UI — `UI.md`

**Question being answered**: "What should this look like?"

Generates **several radically different UI variations** on a single route, switchable via URL parameter and a floating bar on screen.

Characteristics:
- No database, no authentication — UI only
- Multiple visually distinct variations on the same route
- Obeys the existing project routing structure
- Does not invent new folder structure

### Rules common to both

1. **Code clearly marked as prototype** — name that warns it's not production
2. **One command to run** — no configuration
3. **No polish** — no tests, no error handling beyond what's needed to run, no abstractions
4. **Displays state** — after each action (logic) or on each variant switch (UI)
5. **Delete or absorb when done** — don't let it rot in the repo

### When finished

The only artefact worth keeping is the **answer** to the question the prototype was answering. Capture that in a commit message, ADR, issue, or a `NOTES.md` next to the prototype — and then delete the prototype.

## Usage examples

```
I want to prototype a multi-step checkout flow. I'm not sure if the state should live in a global context or a local state machine per step.

/prototype
```

The skill goes to the logic branch and builds a terminal app that simulates the checkout, letting you advance/go back steps and see state displayed at each step.

```
I want to explore how the settings page should be organised. I have 3 different ideas.

/prototype
```

The skill goes to the UI branch and generates the 3 variations on a single route, with a toggle between them.
