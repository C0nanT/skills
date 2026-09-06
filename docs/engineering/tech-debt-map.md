## What it does

Sweeps a whole codebase for technical debt and leaves you a **debt map**: a ranked file of the worst things in the project, each with the file and line range that proves it, a rating for severity, effort and payoff, and a strategy for fixing it without a rewrite. It closes with a four-phase cleanup plan built out of those rows.

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

None. It runs on any repo, and reads `CONTEXT.md`, `CLAUDE.md` and any ADRs where they exist. It writes one file, `.scratch/tech-debt-map/<date>.md`.

## Evidence, cost, and the cap

Three constraints do most of the work, and they are the reason the output differs from a generic "review my code" prompt.

**Evidence.** Every finding cites a line range the agent actually read. A finding inferred from a filename or a directory layout doesn't make the file.

**Cost.** A cue (a long function, a missing test, a duplicated block) is a reason to open the file, not a finding. It becomes a finding only when the agent can name the concrete thing that is harder, slower, or riskier because of it. This is what keeps style preferences off the map, and it is the single question to ask any row you doubt: what does this cost me?

**The cap.** At most 15 findings, ordered by payoff-per-effort rather than by severity, so a High that takes an afternoon outranks a Critical that takes a quarter. An audit with 80 rows is one nobody starts.

A fourth thing worth knowing: anything that looks wrong but might be a deliberate requirement is marked **needs-validation**, with the question to take to the team, instead of being called a bug. In an old codebase the business-rules axis is where the value is, and it is also where the agent knows least.

## Common questions

**How is this different from `/improve-codebase-architecture`?**
Breadth and ending. That skill hunts one class of problem, shallow modules, and ends in a grilling session about the single candidate you pick. This one sweeps every axis and ends in a written, ranked file. They compose: take a structural row from the map into `/improve-codebase-architecture` to design the fix.

**Will it refactor anything?**
No. It reads and writes one markdown file. Turning rows into work is a separate step, `/to-tickets` on the top rows.

**It only looked at part of my repo. Why?**
Auditing everything means auditing nothing well, so it scopes first, usually to the paths that keep showing up in six months of commit history, and it tells you what it left out. Name a module or a subsystem when you invoke it and it takes your direction instead.

## It's working if

- Every row names a file and a line range you can open, and the code there is what the row says it is.
- You can state what each row costs you without re-reading the detail block.
- Phase 1 contains things you could actually ship this week.
- The odd-looking business rules come back as questions to ask, not as verdicts.
- A re-run months later shows resolved rows against the commits that fixed them.

## Where it fits

Periodic maintenance, alongside [improve-codebase-architecture](./improve-codebase-architecture.md): that one is the every-few-days pass on one refactor, this is the occasional whole-project survey. It feeds the main flow at [to-tickets](./to-tickets.md), which turns the top rows into tracked work. For the map over the whole set, see [ask-skills](./ask-skills.md).
