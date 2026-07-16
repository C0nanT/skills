# Productivity

General workflow tools, not code-specific.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[grill-me](./grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[writing-great-skills](./writing-great-skills/SKILL.md)** — Reference for writing and editing skills well: the vocabulary and principles that make a skill predictable.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[caveman](./caveman/SKILL.md)** — Ultra-compressed communication mode: drops articles, filler, and pleasantries while keeping full technical accuracy (~75% fewer tokens). Optionally auto-activated each session via the [claude-hooks](https://github.com/C0nanT/claude-hooks) `SessionStart` hook.
- **[grilling](./grilling/SKILL.md)** — Interview the user relentlessly about a plan, decision, or idea until every branch of the decision tree is resolved.
