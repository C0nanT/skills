---
name: delegate-tickets
description: Orchestrates sequential ticket implementation through fresh subagents, requiring each one to use the /implement skill.
disable-model-invocation: true
---

# Delegate Tickets

Delegate an ordered sequence of tickets to fresh subagents. The main session
only orchestrates; it does not implement tickets.

## Input

Accept an ordered list of ticket files or a ticket directory. Preserve the
user's order. For a directory, sort tickets naturally by numeric filename
prefix. Ask before starting if order or scope is ambiguous.

## Workflow

For each ticket, in order:

1. Start one fresh subagent capable of implementing the ticket.
2. Tell it to implement the ticket using the `implement` skill and preserve all
   existing working-tree changes.
3. Wait until that subagent finishes. Never run ticket subagents in parallel.
4. Start the next ticket only after the current subagent reports clear,
   complete success.
5. If it reports any failure, blocker, unresolved issue, or uncertain result,
   stop immediately. Do not start another ticket. Report the problem to the
   user and wait for instructions.

Use a new subagent for every ticket. Never reuse a previous ticket's session.
Do not implement, test, review, edit, or commit from the orchestrator session.
Do not duplicate the `implement` skill's internal workflow here.

## Subagent prompt

```text
Implement `<ticket-path>` in `<repository-path>` using the `implement` skill.
Preserve all existing working-tree changes. Report clear success or describe
any failure, blocker, unresolved issue, or uncertainty.
```

## Final report

When all tickets succeed, list the completed tickets and their subagent
sessions. If the sequence stops, identify the failed ticket and its problem.
