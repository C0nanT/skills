# `/setup-skills`: Initial Engineering Skills Setup

## What it is

A configuration skill that prepares a repository to use the other engineering skills. Creates configuration files that tell the agent where issues live, which labels to use for triage, and where domain documentation is.

## What it's for

- **Run once per repo** before using any of these skills: `to-tickets`, `to-spec`, `diagnose`, `tdd`, `improve-codebase-architecture`, `zoom-out`
- When these skills seem to be losing context about the issue tracker or labels
- To reconfigure a repo that changed issue trackers

## How to invoke

```
/setup-skills
```

No arguments needed. The skill will explore the repo and guide the configuration.

## How it works

### 5-step process

**1. Exploration**: the agent reads the repository to understand the current state:
- Checks `git remote` to identify if it's GitHub, GitLab, or other
- Looks for `CLAUDE.md` and `AGENTS.md` to see if configuration already exists
- Looks for `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`

**2. Presents and asks**: summarises what it found and asks three questions, one at a time, with an explanation of each:

**Section A: Issue tracker**: Where do issues live?
- GitHub (uses the `gh` CLI)
- GitLab (uses the `glab` CLI)
- Local Markdown (files in `.scratch/`: good for solo projects)
- Other (Jira, Linear, etc.): describe the workflow

**Section B: Triage labels**: Which strings do you use for the 6 canonical states?
- `needs-triage`: maintainer needs to evaluate
- `needs-info`: waiting for more info from reporter
- `ready-for-agent`: fully specified, ready for AFK agent
- `ready-for-human`: needs a human to review the task, the code and whether the feature works
- `wontfix`: will not be actioned
- `done`: work finished and accepted; set by `archive-feature`

If the repo already uses other strings (e.g. `bug:triage`), maps them here.

**Section C: Domain docs**: Layout of `CONTEXT.md` and ADRs:
- Single context: one `CONTEXT.md` + `docs/adr/` at the root
- Multi-context: `CONTEXT-MAP.md` pointing to per-module contexts (monorepos)

**Section D: Git guardrails**: Block destructive git for Claude Code in this repo? (recommended: yes)
- Appends rules to `permissions.deny` in the project's `.claude/settings.json`: `commit`, `push`, `reset`, `clean`, `rebase` (also in the `git -C <dir> …` form), force branch and tag deletes, `checkout .`/`restore .`, `stash drop`/`clear`
- Needs `jq`. Without it, setup stops and says so, and the file is not touched
- With an invalid `settings.json`, it stops and shows the `jq` error; you fix the file and re-run
- With a valid file, it only appends the missing rules: existing allow rules, hooks, env and deny entries stay. Before replacing the file it writes a backup next to it (`settings.json.bak-<timestamp>`)
- With no file, or an empty one, it creates one with the rules. Re-running never duplicates anything

**3. Confirms**: shows a draft of everything that will be written before writing.

**4. Writes**: creates the files:
- Adds an `## Agent skills` block to `CLAUDE.md` or `AGENTS.md` (edits the existing one, never creates both)
- Creates `docs/agents/issue-tracker.md`
- Creates `docs/agents/triage-labels.md`
- Creates `docs/agents/domain.md`
- When Section D is yes: merges the deny rules into `.claude/settings.json` and creates `docs/agents/git-guardrails.md`

**5. Confirms completion**: lists which skills now have the context they need.

## What gets created

```
/
├── CLAUDE.md (or AGENTS.md)   ← "## Agent skills" block added
└── docs/
    └── agents/
        ├── issue-tracker.md   ← where issues live and how to create them
        ├── triage-labels.md   ← mapping of the 6 canonical labels
        ├── domain.md          ← where CONTEXT.md and ADRs are
        └── git-guardrails.md  ← the deny list (only when Section D is yes)
```

With Section D, `.claude/settings.json` changes too (only `permissions.deny` gains entries), and a `settings.json.bak-<timestamp>` appears whenever an existing file is replaced.

## Tips

- You can edit the files in `docs/agents/` manually afterwards: no need to re-run the skill for small changes
- Re-running is only needed if you want to switch issue trackers or start from scratch
- If the repo has `CLAUDE.md`, the block goes there. If it has `AGENTS.md`, it goes there. If neither exists, the skill asks which to create

## Optional: archive finished features

With the **Local Markdown** tracker, finished features pile up in `.scratch/<feature-slug>/`. To park the ones worth keeping (specs, tickets, `POST-DEPLOY.md`, frontend handoffs) outside `.scratch/`, paste this prompt into the agent after `/setup-skills` has run:

````markdown
This project tracks work as local markdown under `.scratch/<feature-slug>/` (specs, tickets, `POST-DEPLOY.md`, frontend handoffs). Finished features pile up there. Create a place to park them for later review, outside `.scratch/`.

Do this:

1. Create `docs/archive/` (use the repo's existing docs root if it isn't `docs/`).
2. Create `docs/archive/README.md`, in English, with this content:

   ```markdown
   # Archive

   Finished features moved out of `.scratch/` for later review: post-deploy checklists, frontend handoffs, specs and tickets worth keeping in the repo.

   - One feature per directory: `docs/archive/<feature-slug>/`, same layout it had in `.scratch/` (`SPEC.md`, `tickets/`, `POST-DEPLOY.md`, handoffs…).
   - Moved by the maintainer, as-is. Not a triage surface: nothing here is active work.
   ```

3. In `docs/agents/issue-tracker.md`, add this paragraph in the section about closing tickets / deleting feature folders:

   > Finished feature folders the maintainer wants to keep for later review (post-deploy, frontend handoff…) move whole to `docs/archive/<feature-slug>/` (see `docs/archive/README.md`).

4. In the `## Agent skills` block of `CLAUDE.md` / `AGENTS.md`, next to the line about `.scratch/`, add: `Finished work kept for review: docs/archive/<feature-slug>/.`

Rules:
- Do **not** move any folder yet. The maintainer decides what gets archived and when; an agent never archives on its own.
- When a folder is moved later, keep its internal layout untouched (a plain `git mv`, so history is preserved).
- Don't create other docs. Be concise. Match the language of the existing docs (technical docs in English, domain terms untranslated).
````

Result:

```
docs/
├── agents/
│   └── issue-tracker.md   ← points finished features to docs/archive/
└── archive/
    └── README.md          ← convention; one <feature-slug>/ per archived feature
```
