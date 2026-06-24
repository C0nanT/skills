# `/setup-skills` — Initial Engineering Skills Setup

## What it is

A configuration skill that prepares a repository to use the other engineering skills. Creates configuration files that tell the agent where issues live, which labels to use for triage, and where domain documentation is.

## What it's for

- **Run once per repo** before using any of these skills: `to-issues`, `to-prd`, `diagnose`, `tdd`, `improve-codebase-architecture`, `zoom-out`
- When these skills seem to be losing context about the issue tracker or labels
- To reconfigure a repo that changed issue trackers

## How to invoke

```
/setup-skills
```

No arguments needed. The skill will explore the repo and guide the configuration.

## How it works

### 5-step process

**1. Exploration** — the agent reads the repository to understand the current state:
- Checks `git remote` to identify if it's GitHub, GitLab, or other
- Looks for `CLAUDE.md` and `AGENTS.md` to see if configuration already exists
- Looks for `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`

**2. Presents and asks** — summarises what it found and asks three questions, one at a time, with an explanation of each:

**Section A — Issue tracker**: Where do issues live?
- GitHub (uses the `gh` CLI)
- GitLab (uses the `glab` CLI)
- Local Markdown (files in `.scratch/` — good for solo projects)
- Other (Jira, Linear, etc.) — describe the workflow

**Section B — Triage labels**: Which strings do you use for the 5 canonical states?
- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting for more info from reporter
- `ready-for-agent` — fully specified, ready for AFK agent
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

If the repo already uses other strings (e.g. `bug:triage`), maps them here.

**Section C — Domain docs**: Layout of `CONTEXT.md` and ADRs:
- Single context: one `CONTEXT.md` + `docs/adr/` at the root
- Multi-context: `CONTEXT-MAP.md` pointing to per-module contexts (monorepos)

**3. Confirms** — shows a draft of everything that will be written before writing.

**4. Writes** — creates the files:
- Adds an `## Agent skills` block to `CLAUDE.md` or `AGENTS.md` (edits the existing one, never creates both)
- Creates `docs/agents/issue-tracker.md`
- Creates `docs/agents/triage-labels.md`
- Creates `docs/agents/domain.md`

**5. Confirms completion** — lists which skills now have the context they need.

## What gets created

```
/
├── CLAUDE.md (or AGENTS.md)   ← "## Agent skills" block added
└── docs/
    └── agents/
        ├── issue-tracker.md   ← where issues live and how to create them
        ├── triage-labels.md   ← mapping of the 5 canonical labels
        └── domain.md          ← where CONTEXT.md and ADRs are
```

## Tips

- You can edit the files in `docs/agents/` manually afterwards — no need to re-run the skill for small changes
- Re-running is only needed if you want to switch issue trackers or start from scratch
- If the repo has `CLAUDE.md`, the block goes there. If it has `AGENTS.md`, it goes there. If neither exists, the skill asks which to create
