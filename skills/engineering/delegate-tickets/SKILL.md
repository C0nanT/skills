---
name: delegate-tickets
description: Orchestrates sequential ticket implementation through fresh subagents, requiring each one to use the /implement skill.
disable-model-invocation: true
---

# Delegate Tickets

Delegate an ordered sequence of tickets to fresh subagents, one at a time. The
main session **only orchestrates** — it does not implement, test, review, edit,
or commit. Do not duplicate the `implement` skill's internal workflow here.

## Input

Accept a ticket directory or an explicit list of ticket files, plus the
repository path (default: the current working directory). Confirm the
repository path before starting — every subagent prompt has to name it
explicitly, since the subagent may not inherit your working directory.

Preserve an explicit list's order as given. For a directory, build the order
yourself:

1. Read every ticket file and take its **Blocked by** line.
2. Order blockers-first (topological). Use the `NN-` filename prefix only to
   break ties between tickets that are mutually unblocked.
3. If the edges disagree with the numeric prefixes, or there's a cycle, stop
   and show the user the conflict. Don't guess.

The user may pass a starting point ("start from ticket 04") — begin there and
leave the earlier tickets alone.

## Isolating each ticket's diff

`/implement` never commits. Without this protocol every ticket's review would
see the accumulated work of all previous tickets. So the **git index is the
baseline**: completed tickets live staged, and the unstaged working tree is
always exactly the current ticket's work.

**Before the first ticket:**

1. Run `git status --short` in the repository.
2. If anything is pending, show it to the user and explain that you'll run
   `git add -A` to fix it as the baseline — this collapses any staged/unstaged
   split they may have built by hand. **Wait for confirmation.** If they
   decline, stop; they can commit or stash first.
3. On confirmation, run `git add -A`.

**After each ticket passes**, run `git add -A` to fold that ticket's work into
the baseline, so the next subagent starts from a clean unstaged tree.

Nothing is ever committed. At the end the whole sequence sits staged, with the
per-ticket commit messages collected for the user.

## Workflow

For each ticket, in order:

1. **Skip if already done** — if every acceptance-criteria checkbox in the
   ticket file is already `- [x]`, report it as already complete and move on.
2. Report progress to the user: `Ticket <N>/<M>: <title>`.
3. Start **one fresh subagent**, using the host's subagent mechanism — `Agent`
   on Claude Code, `Task` on Cursor, the equivalent on other hosts. Use a
   general-purpose subagent with full tool access. If the host has no subagent
   mechanism, stop and tell the user this skill can't run here.
4. Run it **synchronously** — never in the background, never in parallel with
   another ticket. Sequencing is the whole point of this skill; the staging
   baseline is only correct if exactly one ticket is in flight.
5. Wait until it finishes, then **verify** before continuing: the subagent
   reported clear, complete success **and** every acceptance-criteria checkbox
   in the ticket file is now `- [x]` (`/review-axes` syncs those from the code
   at the end of `/implement`). A success report with unchecked criteria is a
   failure — the code didn't do what the ticket asked.
6. On pass, run `git add -A`, record the commit message the subagent produced,
   and start the next ticket.
7. On any failure, blocker, unresolved issue, uncertain result, or unchecked
   criterion — **stop immediately**. Do not stage that ticket's work; leave it
   unstaged so the user can see exactly what it changed. Do not start another
   ticket. Report the problem and wait for instructions.

Use a new subagent for every ticket. Never reuse a previous ticket's session.

## Subagent prompt

```text
Implement `<ticket-path>` in `<repository-path>` using the `implement` skill.

The git index holds work from previous tickets that is NOT yours. Leave it
alone: never run `git add`, `git commit`, `git reset`, `git stash`, or
`git checkout` on it. Your work stays unstaged.

Before `/review-axes` runs, execute `git add -N .` in the repository so new
files you created appear in `git diff`. Then give `/review-axes` "the unstaged
working tree" as its fixed point, so it reviews only your ticket's changes.

Report clear success or describe any failure, blocker, unresolved issue, or
uncertainty. Include the commit message `/implement` generated.
```

## Final report

When all tickets succeed, list the completed tickets with their subagent
sessions and collected commit messages, and remind the user that everything is
staged but uncommitted.

If the sequence stops, identify the failed ticket, its problem, and note that
its work is the only thing left unstaged.
