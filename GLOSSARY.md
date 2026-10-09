# Conan Skills

A collection of agent skills (slash commands and behaviors) loaded by Claude Code. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-skills`. Fork of [mattpocock/skills](https://github.com/mattpocock/skills).

## Language

**Issue tracker**:
The tool that hosts a repo's tickets: GitHub Issues, GitLab, Linear, or a local markdown convention under `.scratch/<feature-slug>/tickets/` (the default). Skills like `to-tickets` and `to-spec` read from and write to it.

_Avoid_: backlog, backlog manager, backlog backend, issue host

**Ticket**:
A single tracked unit of work inside an **Issue tracker**: a bug, task, or slice produced by `to-tickets`. Locally, one markdown file with a `Status:` line.
_Avoid_: issue (use only when naming a real object on an external tracker: a GitHub issue, a GitLab issue)

**Spec**:
The document a set of **Tickets** comes from, written by `to-spec`. Locally, `SPEC.md` beside the feature's `tickets/` folder.

**Decision ticket**:
A `wayfinder` unit: a child **Ticket** of a `wayfinder:map` holding a *question* whose resolution is a decision, not a slice of a build to execute. The **decision** qualifier is what keeps it distinct from an implementation ticket; `wayfinder` introduces the term, then uses "ticket".

**Triage role**:
A canonical state-machine label applied to a **Ticket** (e.g. `needs-triage`, `ready-for-agent`, `ready-for-human`, `done`). Each role maps to a real label string in the **Issue tracker** via `docs/agents/triage-labels.md`; locally it is the `Status:` line.

## Relationships

- An **Issue tracker** holds many **Tickets**
- A **Spec** produces one or more **Tickets**
- A **Ticket** carries one **Triage role** at a time
- A **Decision ticket** is a **Ticket** (a child of a `wayfinder:map`)

## Flagged ambiguities

- "backlog" was previously used to mean both the *tool* hosting tickets and the *body of work* inside it. Resolved: the tool is the **Issue tracker**; "backlog" is no longer used as a domain term.
- "backlog backend" / "backlog manager". Resolved: collapsed into **Issue tracker**.
- "issue" vs "ticket". Resolved: **Ticket** is the unit of work; "issue" only names a real object on an external tracker.
