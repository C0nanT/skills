# claude-hooks

Portable, removable Claude Code hooks. Define each hook as a small JSON file,
then attach/detach them across machines (Ubuntu, WSL) without ever hand-editing
`settings.json`.

The trick: every hook is installed with a unique marker comment
(`# claude-hook:<name>`) as the first line of its command. That marker makes
installs **idempotent** and removals **surgical** — uninstall only ever touches
hooks this tool put there.

## Requirements

- `bash` and `jq` (the only dependency). On Ubuntu/WSL: `sudo apt-get install -y jq`

## Usage

```bash
./install.sh                 # install every hook in hooks/
./install.sh block-rm-rf     # install just hooks/block-rm-rf.json
./list.sh                    # show what this tool has installed
./uninstall.sh block-rm-rf   # remove one hook
./uninstall.sh               # remove ALL hooks this tool installed
```

By default these manage the user-global `~/.claude/settings.json` (shared
across all your projects — ideal for hooks you carry between machines). To
target a different file, e.g. a project's `.claude/settings.json`:

```bash
CLAUDE_SETTINGS=.claude/settings.json ./install.sh
```

`install.sh` is safe to re-run: it re-syncs each hook (picks up edits to the
definition file) instead of duplicating it.

## Defining a hook

One `.json` file per hook in `hooks/`. The filename (without `.json`) becomes
the hook's marker/name.

```json
{
  "event": "PreToolUse",
  "matcher": "Bash",
  "command": "cmd=$(jq -r '.tool_input.command // \"\"'); case \"$cmd\" in *'rm -rf /'*) echo blocked >&2; exit 2 ;; esac; exit 0"
}
```

- `event` (required) — one of: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`,
  `Notification`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`,
  `PreCompact`.
- `matcher` (optional) — tool-name pattern, for `PreToolUse`/`PostToolUse`.
  Omit for events that don't match on a tool.
- `command` (required) — the shell command Claude Code runs. It receives the
  hook event JSON on stdin; exit code `2` blocks the action. You don't write the
  marker yourself — the installer prepends it.

> **Portability & live updates.** These hooks are meant to run on machines that
> only have what `npx skills@latest` installs — no cloned repo. So a hook's
> `command` should reference **skill assets under `~/.claude/skills/<skill>/`**
> (a path present on every machine, symlinked to `~/.agents/skills/`), not a
> path inside this repo. Referencing the file by path also makes the hook
> *live*: it reads the asset at runtime, so updating the skill (via `npx` or by
> editing it) takes effect next session with no reinstall. Self-contained
> inline logic still works, but it's a snapshot — re-run `install.sh <name>`
> after editing it.

## Bundled hooks

- **`git-guardrails.json`** (`PreToolUse` / `Bash`, **live**) — runs
  `~/.claude/skills/git-guardrails-claude-code/scripts/block-dangerous-git.sh`
  (installed by `npx skills`) to block destructive git commands before the agent
  runs them: `git push`, `git commit`, `git reset --hard`, `git clean -f`,
  `git branch -D`, `git checkout .`, `git restore .`, `push --force`,
  `reset --hard`. Blocked commands exit `2` with a message; safe commands
  (`git status`, `git log`, …) pass through. Edit the pattern list in that
  installed script to customize — takes effect next session, no reinstall.
  No-ops if that skill isn't installed.

- **`caveman.json`** (`SessionStart`) — injects the caveman ruleset from
  `~/.claude/skills/caveman/SKILL.md` as hidden session context, so the agent
  starts in token-saving caveman mode every session without typing `/caveman`.
  No-ops cleanly if that skill isn't installed. (This is the same SessionStart
  injection that `scripts/link-skills.sh` does — use one or the other, not both,
  to avoid a duplicate injection.)

## Reusing this in your own hooks project

This directory is self-contained. To start your dedicated hooks repo, copy
`install.sh`, `uninstall.sh`, `list.sh`, `lib/`, and `.gitattributes`, then
drop your own definitions in `hooks/`. Optionally change `HOOK_NS` in
`lib/common.sh` to namespace them under your own project.

## How it works

- Settings are written atomically (`mktemp` + `mv`) — no half-written JSON.
- Install removes any prior copy of the hook's marker, then appends the fresh
  group, so the installed hook always matches the definition file.
- Uninstall filters out matching commands, then prunes emptied groups, events,
  and the `hooks` object, leaving the rest of `settings.json` untouched.
