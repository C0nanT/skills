# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Standing context for every harness lives here. `AGENTS.md` is a versioned pointer that tells Cursor, Codex, and other `AGENTS.md` readers to load this file — edit `CLAUDE.md` only. Shared domain material (`CONTEXT.md`, `.agents/`, `docs/agents/`) is already harness-neutral — do not copy it into `.cursor/rules/` or a second agent markdown file.

## Repo Purpose

A collection of agent skills (slash commands) for Claude Code, organized into bucket folders and distributed via `npx skills@latest`. Skills are plain markdown files (`SKILL.md`) that Claude reads at invocation time.

## Skill Buckets

Skills live under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used, not promoted
- `in-progress/` — beta: public on purpose, feedback wanted, not shipped in the plugin
- `deprecated/` — no longer used

## Invariants

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`'s `skills` array (the Claude Code plugin ships exactly the promoted set). Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear in either.

Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). `.claude-plugin/marketplace.json` makes the repo its own single-plugin marketplace — a fallback the install block explains, not the documented route. Run `claude plugin validate . --strict` after touching either manifest. Why a Claude plugin but not (yet) a Codex one lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).

## Skill Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if content > ~500 lines)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
```

`SKILL.md` frontmatter:
```md
---
name: skill-name
description: Brief description. Use when [specific triggers].
---
```
Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s (`misc/`, `in-progress/`) use a flat list.

Skills in `engineering/` and `productivity/` also have a human-facing docs page at `docs/<bucket>/<skill-name>.md` (the docs tree mirrors those two bucket folders under `skills/`). The published URL is `https://aihero.dev/skills-<skill-name>` regardless of bucket — the docs path is repo organisation only. When you add, rename, or change the behaviour of a skill in `engineering/` or `productivity/`, create or re-sync its docs page following [.agents/writing-docs.md](./.agents/writing-docs.md). A finished page carries four sections — **What it does**, **When to reach for it**, **Common questions**, **It's working if** — and `writing-docs.md` holds the template, the section order, and where to hunt for the questions. Skills in the non-promoted buckets (`misc/`, `in-progress/`, `deprecated/`) get **no** docs page.

[`ask-skills`](./skills/engineering/ask-skills/SKILL.md) is the router that maps every user-reachable skill and how they relate. Whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read `ask-skills`'s `SKILL.md` and update it so the map stays accurate — a new skill it never mentions, or a stale one it still routes to, is a router that lies.

## Scripts

```bash
scripts/list-skills.sh    # Print all SKILL.md paths in the repo
scripts/sync-upstream.sh  # Merge mattpocock/skills (upstream) and strip the skills this fork excludes
```

## Syncing with upstream

This repo is a fork of [mattpocock/skills](https://github.com/mattpocock/skills). Every deliberate difference from it — renamed skills, changed behaviour, dropped paths — is recorded in [.agents/fork-divergences.md](./.agents/fork-divergences.md), and that ledger is what a sync defends. Keep it current the day you decide on a divergence; one that isn't written down is one the next merge silently reverts. Run the sync through the [sync-upstream](./skills/engineering/sync-upstream/SKILL.md) skill, which resolves conflicts against the ledger and then sweeps the cleanly-merged files for divergences the merge took back.

## Runtime Skill Layout (reference `~/.agents/skills`, not the clone)

When configuring skills, hooks, or anything that points at a skill asset at
runtime, target the **npx install location**, not this cloned repo. End users
are not expected to clone this project — they only have what
`npx skills@latest` downloads.

- `npx skills@latest …` installs skills into `~/.agents/skills/<skill>/` (the
  real directory), then symlinks each into `~/.claude/skills/<skill>` →
  `../../.agents/skills/<skill>`.
- This layout exists on every machine (Ubuntu, WSL) after an npx install; the
  repo path (`skills/<bucket>/<skill>/`) does **not**.
- So hooks/configs must reference assets via `~/.claude/skills/<skill>/…`
  (e.g. `~/.claude/skills/caveman/SKILL.md`),
  never a path inside the clone. This keeps them portable across machines and
  "live" (the asset is read at runtime, so `npx` updates take effect without
  reinstalling the hook).

## Domain Language (from CONTEXT.md)

- **Issue tracker** — the tool hosting a repo's issues (GitHub Issues, Linear, local `.scratch/`). Not "backlog".
- **Ticket** — a single tracked unit of work. Use "issue" only when naming a real object on an external tracker (a GitHub issue, a GitLab issue).
- **Triage role** — a state-machine label applied to an issue during triage.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true`, reachable only by the human) or model-invoked (model- or user-reachable). For the full definitions, description conventions, and why a user-invoked skill can invoke model-invoked skills but never another user-invoked one, see [.agents/invocation.md](./.agents/invocation.md).

## Agent skills

### Issue tracker

Tickets live as local markdown files under `.scratch/<feature-slug>/tickets/` (no GitHub integration). See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical strings: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo: one `CONTEXT.md` at the root, ADRs in `.agents/adr/`. See `docs/agents/domain.md`.
