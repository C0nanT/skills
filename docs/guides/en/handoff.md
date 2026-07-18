# `/handoff` — Handoff Document for the Next Session

## What it is

A skill that compacts the current conversation into a structured handoff document, saved to the system temp directory, so a new agent (or you in a new session) can continue the work from where it left off.

## What it's for

- When the session is approaching context limits
- When you want to continue work in another session or another terminal
- When you want to hand off work to another agent or person
- To preserve the context of decisions made before it's lost

## How to invoke

```
/handoff
```

With an argument (describes the focus of the next session):

```
/handoff Continue implementation of the notification system
/handoff Test and debug the checkout flow
```

## How it works

The agent creates a Markdown document with:

**Conversation context** — summary of what was discussed, decided, and built.

**Current state** — where the work stands now: what's done, what's in progress, what's pending.

**References** — instead of duplicating content that already exists in other artefacts (specs, plans, ADRs, issues, commits, diffs), the document *references* them by path or URL.

**Suggested skills** — section that recommends which skills the next agent should invoke to continue the work. For example: "Invoke `/tdd` to implement issue #45" or "Use `/diagnose` to investigate the race condition bug mentioned."

**Sensitive information** is automatically redacted — API keys, passwords, PII do not appear in the document.

The file is saved to the system temp directory (`/tmp` on Linux/Mac, `%TEMP%` on Windows) — not in the workspace, to avoid polluting the repository.

## Usage example

```
Let's stop here. I need to continue tomorrow.

/handoff Resume implementation of the payments module
```

The agent will create something like `/tmp/handoff-2026-06-08-payments.md` with:
- Summary of what was decided about the payment integration
- Reference to the spec published in issue #23
- State: "OrderService interface defined, still need to implement RefundProcessor"
- Suggested skills: "Invoke `/tdd` to implement RefundProcessor following the defined interface"

## Tips

- The argument after `/handoff` is treated as a description of the next session's focus — the document is adjusted to be more useful for that specific goal
- The document is saved to the temp dir and **not** to the project — if you want to preserve it permanently, copy it manually
- Does not duplicate what's in existing commits, specs, or issues — only references them
