Quickstart:

```bash
npx skills add C0nanT/skills --skill=setup-skills
```

```bash
npx skills update setup-skills
```

[Source](https://github.com/C0nanT/skills/tree/main/skills/engineering/setup-skills)

## What it does

`setup-skills` teaches one repo how the engineering skills should behave in it (where issues live, what the triage labels are called, and where the domain docs sit) and records those answers as **config** the other skills read.

It writes config, it does not hard-code behaviour. The engineering chain assumes three files under `docs/agents/` exist; this skill is the one-time bootstrap that produces them, discovered from your actual repo (`git remote`, existing labels, existing `GLOSSARY.md`) and confirmed with you rather than guessed. It is prompt-driven (explore, present what it found, confirm, then write) not a deterministic scaffold.

## When to reach for it

You invoke this by typing `/setup-skills`: the agent won't reach for it on its own.

Reach for it **once per repo, before the first use of any other engineering skill**. If [to-spec](https://aihero.dev/skills-to-spec) or [to-tickets](https://aihero.dev/skills-to-tickets) start guessing where your issues live or applying labels that don't exist, it hasn't been set up here yet. Re-run it only to switch issue trackers or start over: day-to-day tweaks are just edits to `docs/agents/*.md`.

## The four decisions

It walks you through four choices, one at a time, each with a plain-language explainer (it assumes you don't already know the terms):

- **Issue tracker**: where work is tracked, so `to-spec`/`to-tickets` know whether to call `gh`, `glab`, write markdown under `.scratch/`, or follow a workflow you describe. GitHub, GitLab, local markdown, or other.
- **Triage labels**: the strings behind the six canonical roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`, `done`), mapped to labels you've actually configured. On GitHub or GitLab it creates any configured label the tracker lacks. This section always runs; `ready-for-human` means a human has to review the task, the code and whether the feature works.
- **Domain docs**: whether the repo has one `GLOSSARY.md` or a multi-context map, so skills that read domain language look in the right place.
- **Git guardrails**: whether to add `permissions.deny` rules to the project's `.claude/settings.json` so Claude Code refuses destructive git (`push`, `reset`, `clean`, `rebase`, also through `git -C <dir>`, plus force deletes and discard-all commands). Recommended yes; no hooks are installed.

The output is three files: `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`, plus an `## Agent skills` block pointing to them in whichever of `CLAUDE.md` / `AGENTS.md` the repo already uses. The issue tracker file carries a "Wayfinding operations" section for every tracker you can pick, local markdown included (`.scratch/<effort>/map.md` plus `tickets/NN-<slug>.md`), so [wayfinder](./wayfinder.md) knows the map, claim, blocking and frontier format. Local specs are always `SPEC.md`. Those files are the shared substrate the rest of the toolkit stands on. With guardrails on, it also writes `docs/agents/git-guardrails.md` and merges the deny rules into `.claude/settings.json`.

## Common questions

**Will it overwrite my `.claude/settings.json`?**

No. It only appends the deny rules that are missing; allow rules, hooks, env and your own deny entries stay where they are. Before replacing the file it writes a backup next to it (`settings.json.bak-<timestamp>`). If `jq` is not installed, or the file is not valid JSON, it stops and tells you why without touching the file: fix the cause and re-run. A missing or empty file is created with the rules.

**Is it safe to run twice?**

Yes. A second run finds the rules already present and leaves the file, and the backups, alone.

## It's working if

- Three files land under `docs/agents/`, and an `## Agent skills` section appears in your `CLAUDE.md` or `AGENTS.md`.
- The tracker it proposes matches your real `git remote`, and the labels match strings that already exist in your repo.
- Afterwards, `to-tickets` acts on the right place with the right labels instead of asking or guessing.
- With guardrails on, the agent's `git push` (or `git -C <dir> push`) is refused by Claude Code, while your earlier `.claude/settings.json` entries are still there.

## Where it fits

`setup-skills` is a **run-once setup**: the foundation the whole engineering set stands on, not a step you repeat. Its neighbours are the skills that read what it writes: [to-spec](https://aihero.dev/skills-to-spec) / [to-tickets](https://aihero.dev/skills-to-tickets), because they publish into the issue tracker configured here. Run it first; everything downstream assumes it has. When you're unsure which skill or flow fits, [ask-skills](./ask-skills.md) routes you.
