# `/to-tickets` — Convert Plan into Issues

## What it is

A skill that breaks a plan, spec, or spec into independent, grabbable issues on the project issue tracker, using vertical slices (tracer bullets).

## What it's for

- When you have a plan or spec and want to turn it into concrete tickets
- To break large work into independently implementable parts
- When you want to create issues ready for an AFK agent to pick up and execute
- To ensure each ticket is a complete vertical slice, not a horizontal layer

## How to invoke

```
/to-tickets
```

Or passing an existing issue as a starting point:

```
/to-tickets #42
/to-tickets https://github.com/org/repo/issues/42
```

**Prerequisite**: run `/setup-skills` before using for the first time.

## How it works

### What vertical slices are

Each issue is a **tracer bullet slice** — a thin cut that goes through *all* integration layers end-to-end, not a horizontal layer of a single layer.

```
WRONG (horizontal by layer):
  Issue 1: Create database table
  Issue 2: Create API endpoint
  Issue 3: Create UI component

RIGHT (vertical by feature):
  Issue 1: User can see empty orders list (schema + endpoint + basic UI)
  Issue 2: User can create a simple order (form + POST + persistence)
  Issue 3: User can cancel an order (button + endpoint + state update)
```

Each correct slice is demonstrable or verifiable on its own.

### Process

**1. Collects context** — reads what's in the conversation. If an issue number was passed, fetches the full body and comments.

**2. Explores the codebase** — uses the project's domain glossary so issue titles and descriptions use consistent vocabulary.

**3. Drafts slices** — breaks the plan into issues. Each issue can be:
- **HITL** (Human In The Loop): requires human interaction (architectural decision, design review)
- **AFK** (Away From Keyboard): can be implemented and merged without human interaction

Prefers AFK whenever possible.

**4. Presents and refines** — shows the numbered list with:
- Title
- Type (HITL/AFK)
- Blocked by (dependencies)
- User stories covered

Asks if the granularity is right, if dependencies are correct, if any should be split or merged. Iterates until you approve.

**5. Publishes** — creates issues in dependency order (blockers first) so it can reference real IDs in the "Blocked by" field. Uses the template:

```
## What to build
[description of the end-to-end behaviour]

## Acceptance criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by
- #XYZ or "None — can start immediately"
```

## Usage example

```
Here's the spec for the notification system: [paste the spec]

/to-tickets
```

The agent will propose something like: Issue 1 (AFK) - notification when commenting on a task; Issue 2 (AFK) - unread badge on icon; Issue 3 (HITL) - notification preference settings (requires design decision).

## Tips

- Published issues get the `ready-for-agent` label automatically, unless you instruct otherwise
- Code snippets from prototypes can be included in issues when they encode a decision more precisely than prose
- The parent issue is never closed or modified by the skill
