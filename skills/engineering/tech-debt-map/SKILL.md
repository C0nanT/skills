---
name: tech-debt-map
description: Audit one module of a codebase that grew organically and produce a ranked map of its worst technical debt, plus an incremental cleanup plan. Tracks when each module was last reviewed so nothing rots unwatched. Diagnosis only, it changes no code.
disable-model-invocation: true
---

# Tech Debt Map

Produce a **debt map** for **one module**: a ranked, evidence-backed list of what is worst about that module right now, and a plan to fix it a slice at a time.

One module per run, on purpose. A map of a whole project is a map nobody works through, and a refactor that spans everything is a refactor nobody starts. The project gets covered over time instead, module by module, and a committed **review index** remembers when each one was last looked at.

The map is a **diagnosis, not a refactor**. No code changes during this skill. What you hand back is a file the user works through over weeks, and re-runs against later to see what moved.

Two neighbours to stay out of the way of: `/improve-codebase-architecture` hunts one class of problem (shallow modules) and ends in a grilling session about a single candidate; `/review-axes` judges a diff. This one sweeps one module across every axis and ends in a written map.

## Process

### 1. Map the modules

Before anything can be reviewed, the project has to be cut into modules. Some projects have already done it; many have not.

Detect in this order, stopping at the first that yields a real partition:

1. **Declared**: build manifests and project files. Workspace members (`pnpm-workspace.yaml`, `package.json` workspaces, Cargo, Go), `apps/` and `packages/` and `services/` trees, `.csproj` under a solution, Maven or Gradle modules, Django apps.
2. **Source layout**: the top-level directories under the source root, when they carry meaning (`src/billing/`, `src/auth/`) rather than technical layers only.
3. **Domain**: a partition you propose from the vocabulary in `CONTEXT.md` and the names in the code, ignoring which folder the code sits in.

Read `CONTEXT.md` (domain vocabulary), any ADRs, and `CLAUDE.md`/`AGENTS.md` (the standards the repo already committed to). A decision recorded in an ADR is settled, not a finding. Leave out what the team does not own: vendored code, generated files, lockfiles, build output, migrations already applied.

Each module gets a name, a set of path globs, and an **origin**: `declared` or `proposed`. When the origin is `proposed`, say so out loud: "this project declares no modules, so the partition below is mine, correct it if it cuts the wrong way." The boundary of a proposed module is a hypothesis, not a fact about the repo, and the user is the only one who can confirm it.

**Reconcile against the index.** If `docs/tech-debt/README.md` exists, it is the source of truth for the partition: it holds the names and globs used by every past review. Re-detect anyway and compare, then:

- A module on disk but not in the index is **new**: it joins the list as never reviewed.
- A module in the index whose paths have all disappeared is **gone**: mark the row `removed <YYYY-MM-DD>` and keep it. The row is the record that this debt left the project; deleting it loses that.
- A module that looks **renamed or merged** is the one case you ask about, because only the user knows whether `billing` became `payments` or whether they are different things. Guessing here silently throws away the module's history.

**Done when every module has a name, a path set, and an origin, and the index and the disk agree.**

### 2. Pick one module

Show the list and let the user choose. Order it by **how long since the last review, multiplied by how much the module changed since**: a module untouched for a year matters less than one reviewed in March that has taken 200 commits since. Never-reviewed modules come first.

| Module | Paths | Last review | Commits since | Open findings |
| ------ | ----- | ----------- | ------------- | ------------- |

Count the churn with `git log --oneline --since=<last review date> -- <the module's globs>`; for a module never reviewed, count the last six months. Show both raw columns so the user can disagree with your ordering using the same numbers you used.

Recommend the top row in one line, with the reason. If the user says "you pick", take it without asking again. If the user names two modules, review the first and say the second is next time: **one module per run**.

**When the chosen module is too big**, say so and propose a sub-partition, then come back to this step. Too big means the sweep would skim instead of read: the module is effectively the whole source tree, or it holds more code than four sub-agents can read closely. A shallow map of a huge module is worse than no map, because the index then claims the module was reviewed and nobody looks again for months.

**Done when exactly one module is chosen, and the user has seen when it was last reviewed.**

### 3. Sweep

Dispatch four sub-agents in parallel, one per axis group. Each reads [AXES.md](AXES.md) for its own sections and returns findings only, no fixes:

| Sub-agent | AXES.md sections |
| --------- | ---------------- |
| Structure | Architecture, Maintainability |
| Code | Code, Testability |
| Business rules | Business rules |
| Runtime | Performance, Security and robustness |

Each sub-agent gets the module's name and globs, and returns **at most 5 findings, ranked**, each carrying:

- **Evidence**: `path/to/file.ts:120-160`, read and quoted, never inferred from a filename or a directory layout.
- **Cost**: the concrete thing that is harder or riskier because of it. A finding with no cost is a style preference, and style preferences stay out of the map.
- **Blast radius**: what else has to move when this moves.

**Read the module's edges, not just its inside.** Half of what matters (coupling, cycles, a rule smeared across layers, "a one-line change touches five files") only exists *between* modules, so the callers and callees are in scope as evidence. What is not in scope is blaming a neighbour: a finding earns a row only when its evidence sits in a file this module owns. Files outside the module can, and usually should, be named in the description.

**Done when every finding cites a line range the agent actually read, inside the module's paths.**

### 4. Ask what only the team knows

Before writing anything, put the `needs-validation` findings to the user in **one batched round**: numbered, one short question each, with your best guess attached. Then wait. One round, not an interview: this skill ends in a file, not in a conversation.

- An answer becomes a **recorded decision** in the map (the question, the answer, the date). The finding then either joins the ranked table or is dropped as an intentional rule, and the decision says which.
- **"I don't know" keeps the finding out of the table.** It stays `needs-validation`, carrying the exact question and who can answer it. A finding waiting on an answer nobody has is an open question, not prioritisable debt, and mixing the two is how a map becomes a list the team learns to skip. The next review finds the question again and asks again.

**Done when no finding is both unanswered and ranked.**

### 5. Write the map

Read the newest existing map for **this module** first: a finding now fixed is marked **resolved** with the commit that did it, rather than dropped, so consecutive reports show what moved.

Merge the four reports, dropping duplicates and anything whose cost you cannot state. Cap the map at **10 findings**: a list of every small thing is a list nobody acts on. Findings that miss the cut go in a single closing line, counted, not enumerated.

Write to `.scratch/tech-debt-map/<module-slug>/<YYYY-MM-DD>.md`, a new file per review so two dates can be read side by side:

1. **Scope**: the module, its globs, its origin (`declared` or `proposed`), and what was deliberately left out.
2. **The table**, ordered by payoff against blast radius, ties broken toward whatever blocks the work the team is about to do:

   | # | Finding | Location | Axis | Severity | Blast radius | Payoff |
   | - | ------- | -------- | ---- | -------- | ------------ | ------ |
   | 1 | ... | `src/orders/handler.ts:88` | Business rules | 🔴 Critical | Contained | High |

   Rubrics for the three ratings live in [AXES.md](AXES.md#rubrics).
3. **One detail block per row**, in table order, headed by its number: **Problem** (what is there now), **Why it hurts** (the cost, with the example that shows it), **Evidence** (line ranges, and a short quote where the code makes the point better than prose), **Strategy** (the smallest change that removes the pain).
4. **Open questions**: the findings still `needs-validation`, each with its question and who to ask.
5. **Decisions recorded**: what step 4 answered, and what it settled.

The table is the single source of truth for ratings; the detail blocks never restate them.

**Done when every row has a detail block and every detail block has a strategy that preserves current behaviour.**

### 6. Plan the cleanup

Close the file with a phased plan for this module. Each phase lists **row numbers only**, plus one sentence on the order within it:

- **Phase 1, contained**: high payoff, blast radius Contained. Safe to ship this week.
- **Phase 2, complexity**: refactors that make the worst code readable, one seam at a time.
- **Phase 3, structure**: the rows that need a design decision first. Mark the Systemic ones: they reach past this module and are not this module's to schedule alone.

Then one line naming the rows to clear **before the next feature lands in this module**, and why. This line is where a Critical with a Systemic blast radius comes back: the ordering pushes it down the table, and it must not disappear because of that.

**Guardrails do not belong in the phases.** A lint rule, a check, or a practice that stops a finding coming back is a property of the project, not of one module, so it goes in the index (step 7) where it survives and does not get rewritten four different ways by four module reviews.

### 7. Record it, then hand off

Update the review index at `docs/tech-debt/README.md`, creating it if it does not exist:

| Module | Paths | Origin | Last review | Report | Open |
| ------ | ----- | ------ | ----------- | ------ | ---- |
| Billing | `src/billing/**`, `src/invoices/**` | proposed | 2026-09-19 | `.scratch/tech-debt-map/billing/2026-09-19.md` | 7 |

The index is committed on purpose: the reports are working material and live in `.scratch/`, normally gitignored, but "nobody has looked at billing in eight months" is something a team needs to see in review. Below the table, keep the **Guardrails** section, appended to across runs, never rewritten: add what this review learned, skip what is already there.

**Say it before you write it the first time.** This skill advertises itself as changing nothing, and `docs/tech-debt/README.md` is a versioned file, so the first run tells the user it is about to create it, in one line. Later runs update it without asking.

Then tell the user the report path and the top three rows, and offer, without doing it:

- `/to-spec` on the rows worth acting on, to decide what actually changes, then `/to-tickets` to split that into tracked work. The map is a diagnosis, so something has to decide the treatment before it can be sliced.
- `/improve-codebase-architecture` on any row with a Systemic blast radius, where the design decision comes before even the spec.

## Rules

- **Report what the code does now.** Read the code before claiming anything about it; a plausible-sounding problem that isn't there costs the user more than a missed one.
- **Every finding names its cost.** "This is not the standard pattern" is not a cost. "Changing the discount rule means editing four files, and the fifth was missed last time" is.
- **A finding that looks odd but might be deliberate is marked `needs-validation`**, and step 4 asks about it. Business rules are the usual case: strange-looking logic is often a real requirement nobody wrote down.
- **Strategies preserve behaviour** and stay incremental: something one person can do in one sitting without a freeze. Where a finding genuinely needs a rewrite, say so and say what it buys.
- **The partition is a contract.** Once a module's name and globs are in the index, every later review is measured against them. Cut carefully the first time, and when a cut turns out wrong, rename it through step 1 rather than quietly drawing a new line.
- Respect the repo's existing conventions and constraints, including the ones you would have chosen differently.
