---
name: decision-mapping
description: Turn a loose idea with many interdependent open decisions into a sequenced map of one-session investigation tickets, then drive them to resolution one at a time. Use when the user's idea is too loose to plan in one sitting, there are many dependent design decisions, the user wants to map or sequence open decisions, plan prototyping or spike sessions, "plan the planning", or resume work on an existing decision map.
---

# Decision Mapping

This skill bridges loose idea and actionable plan. When a concept has too many open, interdependent design decisions to grill to a conclusion in one session — some unresolvable by discussion alone, others blocked on spikes — it maps those decisions into a sequenced DAG of one-session investigation tickets, then drives them to resolution one at a time.

It is the planning-phase mirror of `/to-issues`: `/to-issues` breaks a *stable* design into implementation tickets; this breaks a *loose* one into investigation tickets. It sits at the front of the pipeline, before `/to-prd`.

## The decision map

The decision map is a single compact Markdown file, one per planning effort, git-tracked alongside the project. It is the canonical artifact — the **whole map is loaded as context into every session**, so it must stay compact.

### Structure

Numbered entries ("tickets"), each its own section keyed by its number:

```markdown
## 1. Should we use a relational or document store?

blocked_by: []

**Question.** ...

**Answer.** ... (once resolved)

**Reasoning.** ...
```

Each ticket carries:

- **Number** — unique, stable, never reused.
- **`blocked_by: [numbers]`** — the dependency edges, forming a DAG. Omit or leave empty when unblocked.
- **Free-form body** — the decision phrased as a question, and once resolved, the answer and reasoning. Keep it minimal but non-lossy. No rigid extra fields (no risk scores, no expiry fields).

Each ticket must be sized to **one context-window session** — resolvable before the agent drifts out of the smart zone. Same sizing constraint as a Ticket in `/to-issues`. Each ticket owns its own section so parallel sessions editing different tickets produce clean diffs.

## Two traversals

**Breadth-first** — used to build or update the map. Fan across the frontier of open decisions. Resolve trivially-decidable ones inline. Tag the rest by how they'll be resolved:

- **discuss** — run `/grilling` for a focused interview.
- **spike** — build throwaway code via `/prototype` to learn something the discussion can't settle. The build step may be delegated to a subagent.
- **defer** — record the question but mark it out-of-scope until a later session unlocks it.

Do not descend into or resolve decisions deeply during breadth-first traversal.

**Depth-first** — used inside a session to drive one ticket as far as it goes until its question resolves. Invoke `/grilling` for the interview itself.

These compose: breadth-first to see the tree, depth-first to drive one node to ground.

## Fog of war

The map is *deliberately* incomplete beyond the frontier — only map as deep as the next spike, because a spike's outcome determines which decisions even exist downstream.

Every session ends with a **re-map**:

1. Record what the session resolved in the ticket's body.
2. Add newly-discovered tickets (with correct `blocked_by` edges).
3. Reopen any previously-resolved ticket the session invalidated, and propagate suspicion to anything `blocked_by` it.

Never try to prove the map complete. The only validation target is that the **next session is correctly chosen**.

## Invocation

There is no auto-discovery. The user always points the skill at what to work on.

### Bootstrap

User invokes with a loose idea.

1. Run breadth-first grilling (via `/grilling`) to surface the open decisions.
2. Write a new decision map — mostly fog, frontier identified, trivially-decidable entries resolved inline.
3. Stop. Map-building is one session's work; do not also resolve tickets.

### Resume

User invokes with a path to an existing map and a ticket number.

1. Load the **whole map** as context.
2. Depth-first grill that ticket to resolution (via `/grilling`).
3. Write the answer and reasoning back into that ticket's section.
4. Re-map: add new tickets, reopen invalidated ones, update `blocked_by` edges.
5. Stop.

The user picks the ticket. You may advise which tickets are currently unblocked, but do not choose. The process is entirely user-driven and never autonomous.

A pair of independent (unblocked, non-overlapping) tickets may be run in parallel as separate sessions; any cross-cutting edits are a git merge the user reconciles.

## Lifecycle

```
loose idea
  → bootstrap map          (this skill)
  → resume sessions        (this skill, one ticket per session)
  → concept stabilises
  → /to-prd absorbs the map
  → /to-issues
  → /implement
  → map archived/deleted   (durable conclusions now live in the PRD)
```
