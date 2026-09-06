---
name: tech-debt-map
description: Audit a codebase that grew organically and produce a ranked map of its worst technical debt, plus a phased, incremental cleanup plan. Diagnosis only, it changes no code.
disable-model-invocation: true
---

# Tech Debt Map

Produce a **debt map**: a ranked, evidence-backed list of what is worst about this codebase right now, and a plan to fix it a slice at a time.

The map is a **diagnosis, not a refactor**. Nothing in the codebase changes during this skill. What you hand back is a file the user can work through over weeks, and re-run against later to see what moved.

Two neighbours to stay out of the way of: `/improve-codebase-architecture` hunts one class of problem (shallow modules) and ends in a grilling session about a single candidate; `/review-axes` judges a diff. This one sweeps the whole project, across every axis, and ends in a written map.

## Process

### 1. Scope

Auditing everything means auditing nothing well, so decide where to look before you look.

- If the user named a direction (a module, a subsystem, a pain point), take it.
- Otherwise find the **hot spots**: `git log --oneline --since='6 months ago' --name-only` and count which paths keep coming up. Churn is where debt actually costs money, so let those paths pull your attention first. Widen the net when churn is evenly spread.
- Read `CONTEXT.md` (domain vocabulary), any ADRs, and `CLAUDE.md`/`AGENTS.md` (the standards the repo already committed to). A decision recorded in an ADR is settled, not a finding.
- Leave out what the team does not own: vendored code, generated files, lockfiles, build output, migrations already applied.

Tell the user the scope you picked, in one short list of paths with a reason each, and start the sweep. **Done when every path in scope has a stated reason for being there.**

### 2. Sweep

Dispatch four sub-agents in parallel, one per axis group. Each reads [AXES.md](AXES.md) for its own sections and returns findings only, no fixes:

| Sub-agent | AXES.md sections |
| --------- | ---------------- |
| Structure | Architecture, Maintainability |
| Code | Code, Testability |
| Business rules | Business rules |
| Runtime | Performance, Security and robustness |

Each sub-agent gets the scope from step 1, and returns **at most 8 findings, ranked**, each carrying:

- **Evidence**: `path/to/file.ts:120-160`, read and quoted, never inferred from a filename or a directory layout.
- **Cost**: the concrete thing that is harder or riskier because of it. A finding with no cost is a style preference, and style preferences stay out of the map.
- **Blast radius**: what else has to move when this moves.

**Done when every returned finding cites a line range the agent actually read.**

### 3. Write the map

Merge the four reports, dropping duplicates and anything whose cost you cannot state. Cap the map at **15 findings**: a list of every small thing is a list nobody acts on. Findings that miss the cut go in a single closing line, counted, not enumerated.

Write to `.scratch/tech-debt-map/<YYYY-MM-DD>.md`:

1. **Scope**: the paths from step 1, and what was deliberately left out.
2. **The table**, ordered by payoff-per-effort, ties broken toward whatever blocks the work the team is about to do:

   | # | Finding | Location | Axis | Severity | Effort | Payoff |
   | - | ------- | -------- | ---- | -------- | ------ | ------ |
   | 1 | ... | `src/orders/handler.ts:88` | Business rules | 🔴 Critical | Medium | High |

   Rubrics for the three ratings live in [AXES.md](AXES.md#rubrics).
3. **One detail block per row**, in table order, headed by its number: **Problem** (what is there now), **Why it hurts** (the cost, with the example that shows it), **Evidence** (line ranges, and a short quote where the code makes the point better than prose), **Strategy** (the smallest change that removes the pain).

The table is the single source of truth for ratings; the detail blocks never restate them.

**Done when every row has a detail block and every detail block has a strategy that preserves current behaviour.**

### 4. Plan the cleanup

Close the file with a phased plan. Each phase lists **row numbers only**, plus one sentence on the order within it:

- **Phase 1, quick wins**: low effort, high payoff. Safe to ship this week.
- **Phase 2, complexity**: refactors that make the worst code readable, one seam at a time.
- **Phase 3, structure**: the findings that need a design decision first.
- **Phase 4, guardrails**: the practices, checks, or lint rules that stop these findings coming back.

Then one line naming the rows that should be cleared **before** the next feature lands, and why.

### 5. Hand off

Tell the user the file path and the top three rows. Then offer, without doing it:

- `/to-tickets` on the top rows, to turn the map into tracked work.
- `/improve-codebase-architecture` on any structural row, to design the fix properly before building it.

Re-running this skill later reads the newest map first: a finding that is now fixed is marked **resolved** with the commit that did it, rather than dropped, so the file shows what moved.

## Rules

- **Report what the code does now.** Read the code before claiming anything about it; a plausible-sounding problem that isn't there costs the user more than a missed one.
- **Every finding names its cost.** "This is not the standard pattern" is not a cost. "Changing the discount rule means editing four files, and the fifth was missed last time" is.
- **A finding that looks odd but might be deliberate is marked `needs-validation`**, with the exact question to ask the team. Business rules are the usual case: strange-looking logic is often a real requirement nobody wrote down.
- **Strategies preserve behaviour** and stay incremental: something one person can do in one sitting without a freeze. Where a finding genuinely needs a rewrite, say so and say what it buys.
- Respect the repo's existing conventions and constraints, including the ones you would have chosen differently.
