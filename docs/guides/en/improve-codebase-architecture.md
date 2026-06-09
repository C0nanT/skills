# `/improve-codebase-architecture` — Codebase Architecture Improvement

## What it is

A skill that analyses your codebase looking for "deepening" opportunities — refactorings that transform shallow modules into deep modules, making the code more testable and navigable by AIs.

## What it's for

- When the project has turned into a "big ball of mud" and you don't know where to start
- To identify tightly-coupled modules that should have clear interfaces
- To find code that's hard to test
- To make the codebase easier to navigate (for you and for the agent)
- Recommended to run every few days on active projects

## How to invoke

```
/improve-codebase-architecture
```

## How it works

### Skill vocabulary

The skill uses specific, consistent terminology:

- **Module** — anything with an interface and an implementation
- **Depth** — how much behaviour is hidden behind a small interface. Deep module = lots of behaviour behind a simple interface. Shallow module = interface almost as complex as the implementation
- **Seam** — where an interface lives; a place where behaviour can be changed without directly editing code
- **Leverage** — what callers gain from a module's depth

**Deletion test**: imagine deleting the module. If the complexity disappears, it was a useless pass-through. If the complexity reappears spread across N callers, the module was earning its place.

### Process

**1. Exploration**

Reads `CONTEXT.md` and ADRs first. Then navigates the codebase organically, looking for:
- Where understanding a concept requires jumping across many small modules?
- Where modules are shallow (the interface is almost as complex as the implementation)?
- Where code is hard to test?
- Where coupled modules leak through their interfaces?

**2. HTML report**

Generates a visual HTML file with Tailwind and Mermaid, saved to `/tmp/architecture-review-<timestamp>.html` and automatically opened in the browser. For each refactoring candidate, the report shows:
- Which files are involved
- Why the current architecture causes friction
- What would change
- Benefits in terms of locality and leverage
- Before/after diagram drawn visually
- Recommendation strength: `Strong`, `Worth exploring`, or `Speculative`

The report ends with a "Top recommendation" section — which candidate to tackle first and why.

**3. Grilling loop**

When you choose a candidate, the skill enters interview mode to work through the design: constraints, dependencies, shape of the deepened module, what goes behind the seam, which tests survive.

Side effects during grilling:
- New terms are added to `CONTEXT.md` inline
- Rejection decisions with strong rationale generate an ADR offer

## Usage example

```
The codebase is growing fast and getting hard to change. I want to see where I can improve the architecture.

/improve-codebase-architecture
```

The agent will explore, generate the HTML report, you open it in the browser, pick a candidate, and enter a conversation loop to work through the refactoring design.

## Tips

- Run periodically, not only when the project is already problematic
- The report opens automatically in the browser — look for the path in the output if it doesn't open
- The skill doesn't propose new interfaces until you choose a candidate — avoids wasting tokens
- Contradictions with existing ADRs are flagged in the report with a warning, not silently ignored
