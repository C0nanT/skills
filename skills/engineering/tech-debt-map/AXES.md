# Axes

What each sub-agent hunts for, and how to rate what it finds. Read only the sections your dispatch names.

Each axis lists **cues**: the shapes worth looking at. A cue is a reason to open the file, not a finding. What makes it a finding is the **cost**: the concrete thing that is harder, slower, or riskier because the code is like this. Anything you cannot attach a cost to belongs in the noise floor, not the map.

## Architecture

Cues:

- One module holding responsibilities that change for unrelated reasons.
- Circular dependencies, and import cycles the build tolerates.
- Business logic living in transport code (controllers, handlers, components) or in the persistence layer.
- The same logic implemented in two layers, each unaware of the other.
- Two or more architectural patterns in play for the same kind of problem, so a newcomer cannot tell which one to follow.
- An abstraction with a single implementation and no substitution anywhere, or a concept that clearly wants one and has none.

The strongest architecture finding names a **change that should be local and isn't**.

## Code

Cues:

- Functions and classes long enough that no one reads them top to bottom.
- Duplicated logic, especially copies that have already drifted apart.
- Conditionals that need a whiteboard: deep nesting, long boolean chains, flag arguments that fork the whole body.
- Magic values, and constants that mean the same thing defined in several places.
- Names that mislead (a `get` that writes, a `Manager` that is a bag of unrelated helpers).
- Error handling that varies by file: swallowed exceptions, logged-and-continued, thrown strings.
- Dead code, and commented-out blocks kept "just in case".
- Comments explaining what the code does, where a rename would have said it.
- Temporary fixes that outlived their reason (`TODO`, `HACK`, a workaround for a bug fixed upstream two years ago).

## Business rules

The highest-value axis in an organically grown codebase, because these findings are the ones nobody can reconstruct from the code alone.

Cues:

- The same rule implemented in more than one place, with any drift between the copies.
- Rules buried in a controller, a component, a trigger, or a cron job.
- Behaviour that depends on execution order, or on a side effect happening first.
- Exceptions handled by a special case bolted onto a general path.
- Thresholds, cutoffs, and codes that look arbitrary.
- The same concept answered differently in two parts of the system.

For every rule you find, say **where it lives and what depends on it**. When it looks wrong but could be a real requirement, mark it `needs-validation` and write the question to ask, rather than calling it a bug.

## Maintainability

Cues:

- A one-line change that requires edits in several files, and the list of files is not discoverable.
- Implicit coupling: a shared mutable object, a global, an env var read deep in the stack.
- Low cohesion: a module whose parts have nothing to do with each other.
- A widely reused component that grew a prop or flag per caller.
- Side effects in code that reads like a pure calculation.

The test: pick a plausible next change and trace what it touches. That trace is the evidence.

## Testability

Cues:

- Risky or complex logic with no test at all.
- Logic reachable only through infrastructure (a live DB, a real HTTP call, a clock, a filesystem).
- Constructors or module bodies that do work, so nothing can be instantiated in isolation.
- Dependencies that cannot be substituted, so a test needs the whole world.
- Tests that assert on implementation details and break on every refactor.

Missing tests are not a finding on their own. A finding is **untested code that carries risk**: money, auth, data loss, or the rules from the Business rules axis.

## Performance

Cues:

- N+1 queries, and queries inside loops.
- The same work repeated within a request, or across requests, with no memoisation or cache.
- Loading whole collections to use one field, or to count them.
- External calls that could be batched, parallelised, or skipped.
- Work done in the wrong place: in the app what the database does better, in a request what a job should do.

Report what is measurably or structurally wrong, and say which. A cue with no evidence of load behind it is a note, not a finding: premature optimisation is itself debt.

## Security and robustness

Cues:

- Input trusted at a boundary: unvalidated payloads, params interpolated into queries or commands.
- Authorisation checked in some paths and not others, or checked in the UI only.
- Data over-exposed by an endpoint or a serializer (internal fields, other users' records).
- Secrets, tokens, or credentials in source or in committed config.
- Errors that leak internals to the client, or that hide failures from the logs.
- Dependencies that are unmaintained, badly out of date, or used in an unsafe mode.

## Rubrics

**Severity**, how much it costs today:

| | | |
| - | - | - |
| 🔴 | Critical | Causing bugs, data risk, or security exposure now, or blocking work already scheduled. |
| 🟠 | High | Reliably slows or endangers changes in an area that keeps changing. |
| 🟡 | Medium | Real cost, in code that rarely moves. |
| 🟢 | Low | Convention or clarity. Worth doing while passing through. |

**Effort**, for one person: **Low** a sitting, **Medium** a few days, **High** needs a design decision or a coordinated change.

**Payoff**, what fixing it buys: **High** removes a class of bug or unblocks a whole area, **Medium** makes one area meaningfully easier, **Low** local improvement.

Order the map by payoff-per-effort, not by severity: a 🟠 with Low effort and High payoff outranks a 🔴 that needs a quarter.
