# `/diagnose` — Disciplined Bug Diagnosis

## What it is

A skill for debugging hard bugs and performance regressions systematically. Instead of "looking at the code and guessing", it forces a disciplined process that almost always finds the root cause.

## What it's for

- Bugs you can't reproduce consistently
- Performance that got worse but you don't know why
- Intermittent errors or "sometimes it happens"
- Any situation where you've been staring at the code for a long time without getting anywhere

## How to invoke

```
/diagnose
```

Describe the bug in the same message or a prior message. The skill will drive the process from there.

## How it works

The skill operates in **6 phases**:

### Phase 1 — Build a feedback loop

**This is the most important part.** The goal is to create an automatic, fast, and deterministic way to reproduce the bug — a script, test, or command that results in "passed" or "failed".

Examples of what can be used:
- An automated test (unit, integration, e2e)
- A `curl` script against the local server
- A Playwright script that opens the browser and clicks the right things
- A CLI invocation with a fixed input
- A script that runs the same input 1000 times looking for the failure

If it's not possible to build this loop, the skill stops and asks the user for help (environment access, captured logs, etc.).

### Phase 2 — Reproduce

Confirms that the loop actually reproduces the described bug, not a similar different bug.

### Phase 3 — Hypotheses

Generates 3–5 ranked hypotheses before testing any of them. Each hypothesis must be falsifiable: "if X is the cause, then changing Y will make the bug disappear". Shows the list to the user before testing — someone with domain context often re-ranks on the spot.

### Phase 4 — Instrument

Tests hypotheses one at a time. Prefers debugger/REPL over logs. All debug logs are tagged with a unique prefix (e.g. `[DEBUG-a4f2]`) for easy cleanup later.

### Phase 5 — Fix + regression test

Writes the regression test *before* the fix, if there's a good seam. Applies the fix. Verifies that the original loop passes.

### Phase 6 — Cleanup + post-mortem

Removes all debug logs, deletes temporary prototypes, documents what caused the bug in the commit/PR. Asks: what would have prevented this bug? If the answer involves architectural change, forwards to `/improve-codebase-architecture`.

## Usage example

```
We have a bug in checkout: sometimes the order is saved with "pending" status even after payment is approved. Only happens in production, can't reproduce locally.

/diagnose
```

The skill will guide you through building a feedback loop (perhaps replaying a captured production trace), then through hypotheses, instrumentation, and fix.

## Tips

- Don't skip Phase 1. A 2-second feedback loop is a superpower. Without it, you're flying blind.
- For non-deterministic bugs, the goal isn't a clean reproduction — it's a *higher reproduction rate*. Run 100 times, add stress, parallelise.
