---
name: delegate-tickets
description: Orchestrates sequential ticket implementation through fresh subagents, requiring each one to use the /implement skill.
disable-model-invocation: true
---

# Delegate Tickets

Delegate an ordered sequence of tickets to fresh subagents, one at a time. The
main session **only orchestrates**: it does not implement, test, review, edit,
or commit. Do not duplicate the `implement` skill's internal workflow here.

## Input

Accept a ticket directory or an explicit list of ticket files, plus the
repository path (default: the current working directory). Confirm the
repository path before starting: every subagent prompt has to name it
explicitly, since the subagent may not inherit your working directory.

Preserve an explicit list's order as given. For a directory, build the order
yourself:

1. Read every ticket file and take its **Blocked by** line.
2. Order blockers-first (topological). Use the `NN-` filename prefix only to
   break ties between tickets that are mutually unblocked.
3. If the edges disagree with the numeric prefixes, or there's a cycle, stop
   and show the user the conflict. Don't guess.

The user may pass a starting point ("start from ticket 04"): begin there and
leave the earlier tickets alone.

## Difficulty gate

This skill only runs mid-level work unattended. Before starting, read the
`Difficulty:` line of **every** ticket in the sequence, not just the next one,
so a Heavy ticket stops the run before any work is done.

- **Standard** or **Light**: runs.
- **Heavy**, or **no `Difficulty:` line**: stop the sequence before that ticket
  and tell the user that ticket needs Opus and a human nearby, so it has to be
  run by hand with `/implement`. A missing line is a blocker, never a default
  tier. Tickets that come before it in the order may still run.

## Isolating each ticket's diff

`/implement` commits its work to the current branch when it finishes, so **each
ticket is one commit** and the uncommitted working tree is always exactly the
current ticket's work while it runs.

**Before the first ticket:**

1. Run `git status --short` in the repository.
2. If anything is pending, show it to the user and stop: they commit or stash
   it first, so the first ticket's commit carries only that ticket's work.

## Workflow

For each ticket, in order:

1. **Skip if already done**: if every acceptance-criteria checkbox in the
   ticket file is already `- [x]`, report it as already complete and move on.
2. Report progress to the user: `Ticket <N>/<M>: <title>`.
3. Start **one fresh subagent**, using the host's subagent mechanism: `Agent`
   on Claude Code, `Task` on Cursor, the equivalent on other hosts. Use a
   general-purpose subagent with full tool access, on **Sonnet** (or the host's
   equivalent mid-level model) at **`effort: medium`**. If the host cannot set
   the model or effort per spawn, say so to the user and stop rather than
   spawning at whatever the session uses. If the host has no subagent
   mechanism, stop and tell the user this skill can't run here.
4. Run it **synchronously**, never in the background, never in parallel with
   another ticket. Sequencing is the whole point of this skill; each commit
   holds one ticket only if exactly one ticket is in flight.
5. Wait until it finishes, then **verify** before continuing: the subagent
   reported clear, complete success, its work is committed (`git status
   --short` is clean), **and** every acceptance-criteria checkbox in the
   ticket file is now `- [x]` (`/review-axes` syncs those from the code
   at the end of `/implement`). A success report with unchecked criteria is a
   failure: the code didn't do what the ticket asked.
6. On pass, record the ticket's commit (`git log -1 --oneline`) and start the
   next ticket.
7. On any failure, blocker, unresolved issue, uncertain result, or unchecked
   criterion: **stop immediately**. Leave that ticket's work as it is (its
   commit, or whatever it left uncommitted) so the user can see exactly what it
   changed. Do not start another ticket. Report the problem and wait for instructions.

Use a new subagent for every ticket. Never reuse a previous ticket's session.

## Subagent prompt

```text
Implement `<ticket-path>` in `<repository-path>` using the `implement` skill.

When you invoke `/review-axes`, give it "the unstaged working tree" as its
fixed point, so it reviews only your ticket's changes, and give it
`<ticket-path>` as its spec argument, so it checks and ticks that ticket's
checkboxes.

Nobody is available to answer you. Any question you would ask the user (a
missing spec, an effort gate, an ambiguity) is a blocker: stop and report the
question. Never answer it yourself and never do that work inline.

Report clear success or describe any failure, blocker, unresolved issue, or
uncertainty. Include the hash of the commit `/implement` made.
```

## Final report

When all tickets succeed, list the completed tickets with their subagent
sessions and commits.

If the sequence stops, identify the failed ticket, its problem, and where its
work is (its commit, or the uncommitted working tree).
