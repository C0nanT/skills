## What it does

Sweeps **one module** of a codebase for technical debt and leaves you a **debt map**: a ranked file of the worst things in that module, each with the file and line range that proves it, a rating for severity, blast radius and payoff, and a strategy for fixing it without a rewrite. It closes with a three-phase cleanup plan built out of those rows.

One module per run is the whole point. A map of an entire project is a map nobody works through, so the project gets covered a piece at a time instead, and a committed index remembers when each module was last looked at. Before it can review anything it has to work out what the modules *are*, which many projects have never decided; where the build system doesn't declare them, it proposes a partition and says out loud that the cut is its own.

It is a diagnosis and it changes no code. The map is something you work through over weeks, and re-run the skill against later to see what actually moved.

## When to reach for it

You invoke this by typing `/tech-debt-map`, and the agent won't reach for it on its own.

| Situation | Reach for |
| --------- | --------- |
| A project that grew organically and now resists change, and you don't know where the worst of it is | `/tech-debt-map` |
| You want one architectural refactor designed properly, start to finish | [improve-codebase-architecture](./improve-codebase-architecture.md) |
| You want the diff on your branch judged | [review-axes](./review-axes.md) |
| You want someone else's merge request judged | [review-mr](./review-mr.md) |

## Prerequisites

None to install, but know what it writes. Reports go to `.scratch/tech-debt-map/<module>/<date>.md`, one file per review so two dates can be read side by side. The **review index** goes to `docs/tech-debt/README.md`, which is a versioned file: the skill tells you before creating it the first time. It reads `CONTEXT.md`, `CLAUDE.md` and any ADRs where they exist.

## The module, and the index

The two ideas worth carrying away.

**The module** is the unit of work. It comes from the build system where one exists (workspaces, `packages/`, projects in a solution), from the source layout where that carries meaning, and otherwise from a partition the skill proposes out of your domain vocabulary. A proposed module is labelled `proposed`, because its boundary is a guess about your system and you are the only one who can confirm it. Findings have to be anchored in a file the module owns, but the module's callers and callees are read too: coupling and a rule smeared across layers only exist *between* modules, and a review blind to the edges misses the worst of them.

**The index** is the memory. `docs/tech-debt/README.md` carries one row per module: its globs, whether the partition was declared or proposed, when it was last reviewed, and how many findings are still open. That row is why the skill can open with "nobody has audited billing in eight months, and it has taken 90 commits since", instead of asking you to remember. It is also the source of truth for the partition itself, so a later review measures the same module against the same boundary rather than redrawing the line and losing the history.

Because the index is a project-wide document, the **guardrails** live there too: the lint rules and checks that stop a finding coming back are properties of the project, not of whichever module happened to surface them, and each review appends to that list instead of rewriting it.

## Evidence, cost, and the cap

Three constraints do most of the work, and they are the reason the output differs from a generic "review my code" prompt.

**Evidence.** Every finding cites a line range the agent actually read. A finding inferred from a filename or a directory layout doesn't make the file.

**Cost.** A cue (a long function, a missing test, a duplicated block) is a reason to open the file, not a finding. It becomes a finding only when the agent can name the concrete thing that is harder, slower, or riskier because of it. This is what keeps style preferences off the map, and it is the single question to ask any row you doubt: what does this cost me?

**The cap.** At most 10 findings per module, ordered by payoff against blast radius rather than by severity, so a High that is contained to the module outranks a Critical that needs a cross-team decision. An audit with 80 rows is one nobody starts. Because that ordering deliberately sinks the biggest problems, the plan ends with a line naming the rows to clear before the next feature lands, which is where a sunk Critical comes back up.

A fourth thing worth knowing: anything that looks wrong but might be a deliberate requirement is marked **needs-validation**, and the skill asks you about it in a single batched round before it writes the file. In an old codebase the business-rules axis is where the value is, and it is also where the agent knows least.

## Common questions

**Why won't it just audit the whole project?**
Because the output would be unusable. The point of the map is that you act on it, and the ranked list that gets acted on is the one short enough to finish. Covering the project happens over several runs, and the index is what makes that a plan rather than a thing you lose track of.

**My project has no modules. What does it do?**
Proposes some, from your domain vocabulary and the names in the code, and labels them `proposed` so you know the cut is its own. Correct it there and then: the partition is stored in the index and every later review is measured against it, so a bad first cut is the one mistake that compounds.

**I answered "I don't know" to one of its questions. Where did that finding go?**
Into an open-questions section, with the exact question and who can answer it, and deliberately out of the ranked table. A finding waiting on an answer nobody has is a question, not prioritisable debt, and the next review will ask again.

**Why is there no effort estimate?**
Because an agent guessing how many days *you* need is guessing. Blast radius measures the same useful thing (how much has to move together) and is a fact the repo can answer: Contained fits inside the module, Module+ drags the callers in, Systemic needs a design decision.

**Will it refactor anything?**
No. It reads code and writes two markdown files. Turning rows into work is a separate step: `/to-spec` to decide what actually changes, then `/to-tickets` to slice it.

## It's working if

- Every row names a file and a line range you can open, and the code there is what the row says it is.
- You can state what each row costs you without re-reading the detail block.
- Phase 1 contains things you could actually ship this week.
- The odd-looking business rules come back as questions to ask, not as verdicts.
- The index tells you which module is most overdue before you have to think about it.
- A re-run months later shows resolved rows against the commits that fixed them.

## Where it fits

Periodic maintenance, alongside [improve-codebase-architecture](./improve-codebase-architecture.md): that one is the every-few-days pass on one refactor, this is the recurring per-module survey. It feeds the main flow at [to-spec](./to-spec.md), which decides what to change, and then [to-tickets](./to-tickets.md), which turns that into tracked work. For the map over the whole set, see [ask-skills](./ask-skills.md).
