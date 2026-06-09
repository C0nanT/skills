# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo Purpose

A collection of agent skills (slash commands) for Claude Code, organized into bucket folders and distributed via `npx skills@latest`. Skills are plain markdown files (`SKILL.md`) that Claude reads at invocation time.

## Skill Buckets

Skills live under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

## Invariants

- Every skill in `engineering/`, `productivity/`, or `misc/` **must** have an entry in the top-level `README.md` and in `.claude-plugin/plugin.json`.
- Skills in `personal/`, `in-progress/`, and `deprecated/` **must not** appear in either.
- Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.
- Each bucket folder has a `README.md` listing every skill in the bucket with a one-line description, skill name linked to its `SKILL.md`.

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

## Scripts

```bash
scripts/link-skills.sh    # Symlink all skills into ~/.claude/skills + inject caveman SessionStart hook
scripts/unlink-skills.sh  # Remove symlinks (leaves non-repo entries untouched)
scripts/list-skills.sh    # Print all SKILL.md paths in the repo
```

Run `scripts/link-skills.sh` after adding a new skill to make it available locally without reinstalling.

## Domain Language (from CONTEXT.md)

- **Issue tracker** — the tool hosting a repo's issues (GitHub Issues, Linear, local `.scratch/`). Not "backlog".
- **Issue** — a single tracked unit of work. Not "ticket" unless quoting external systems.
- **Triage role** — a state-machine label applied to an issue during triage.
