---
name: setup-conan-skills
description: Configure the Claude Code hooks that the conan-skills set depends on after installing via `npx skills@latest add <user>/skills`. Wires up the caveman `SessionStart` hook (auto-injects caveman mode every session, read live from the installed symlink) and the git-guardrails `PreToolUse` hook (blocks destructive git commands). Use when the user says "set up conan skills", "configure the skill hooks", "/setup-conan-skills", or after a fresh install.
disable-model-invocation: true
---

# Setup Conan Skills

Some skills in this set only work once a Claude Code **hook** is wired up — a skill
file alone can't make Claude do something on *every* session or *before* a tool runs.
This skill writes those hooks into `settings.json` and creates the helper scripts they
reference. It is the manual companion to the repo's own `scripts/link-skills.sh` (which
the maintainer uses for local dev); end users who installed through `npx skills add`
run this instead.

Two hooks are configured:

| Skill | Hook event | Effect |
| --- | --- | --- |
| **caveman** | `SessionStart` | Injects the caveman-mode instructions at the start of every session — no need to type `/caveman`. The hook reads `~/.claude/skills/caveman/SKILL.md` **live through the installed symlink**, so edits to the skill take effect with no reconfiguration. |
| **git-guardrails** | `PreToolUse` (Bash) | Intercepts every Bash command and blocks destructive git operations (`git push`, `git reset --hard`, `git clean -f`, `git commit --amend`, `git branch -D`, `git checkout .` / `git restore .`). |

This is a deterministic config task. Do the steps below exactly; don't improvise the JSON
shape, marker strings, or paths — `uninstall.sh` depends on them to clean up.

## Prerequisites

- `jq` must be installed (`command -v jq`). Both the merge below and the caveman/guardrails
  hooks call it at runtime. If it's missing, stop and tell the user to install it first.
- The skills must already be installed (symlinks present under `~/.claude/skills/`). Check
  that `~/.claude/skills/caveman/SKILL.md` exists. If it doesn't, tell the user to run
  `npx skills@latest add <user>/skills` first (and select the `caveman` and
  `git-guardrails-claude-code` skills).

## Step 1 — Choose scope

Ask the user:

> Configure these hooks **globally** (all projects, recommended) or for **this project only**?

- **Global** (recommended, and what `uninstall.sh` cleans automatically):
  - settings file: `~/.claude/settings.json`
  - guardrails script: `~/.claude/hooks/conan-git-guardrails.sh`
- **Project only**:
  - settings file: `./.claude/settings.json`
  - guardrails script: `./.claude/hooks/conan-git-guardrails.sh`
  - Tell the user that `uninstall.sh` only cleans the global location, so they'll need to
    remove the project hooks by hand later.

Set `SETTINGS` and `HOOK_DIR` accordingly for the commands below. The examples use the
global paths.

## Step 2 — Ensure the settings file exists and is valid JSON

```bash
SETTINGS="$HOME/.claude/settings.json"      # or ./.claude/settings.json for project scope
mkdir -p "$(dirname "$SETTINGS")"
if [ ! -s "$SETTINGS" ] || ! jq -e . "$SETTINGS" >/dev/null 2>&1; then
  echo '{}' > "$SETTINGS"
fi
```

Never overwrite the file wholesale — every change below is a `jq` merge that preserves
existing keys.

## Step 3 — Add the caveman `SessionStart` hook

The command is marked with the comment `# conan-caveman-autostart` so it can be found and
removed cleanly. It reads the SKILL.md live through the symlink and wraps it as
`additionalContext`, which is the documented way a `SessionStart` hook injects context.

```bash
CAVEMAN_CMD='# conan-caveman-autostart
cat "$HOME/.claude/skills/caveman/SKILL.md" | jq -Rs '\''{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}}'\'''

jq --arg cmd "$CAVEMAN_CMD" '
  if ([ (.hooks.SessionStart // [])[]?.hooks[]?.command ] | any(test("conan-caveman-autostart")))
  then .
  else .hooks.SessionStart = ((.hooks.SessionStart // []) +
        [{"matcher": "", "hooks": [{"type": "command", "command": $cmd}]}])
  end
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
```

The `if … any(test(...))` guard makes this idempotent — re-running never adds a duplicate.

## Step 4 — Create the git-guardrails helper script

Write this **exact** content to `$HOOK_DIR/conan-git-guardrails.sh` and `chmod +x` it.
It is self-contained (no dependency on the skill's bundled script), so the hook keeps
working regardless of the skill's internal layout.

```bash
HOOK_DIR="$HOME/.claude/hooks"              # or ./.claude/hooks for project scope
mkdir -p "$HOOK_DIR"
cat > "$HOOK_DIR/conan-git-guardrails.sh" <<'EOF'
#!/usr/bin/env bash
# conan-git-guardrails — blocks destructive git commands.
# Installed by /setup-conan-skills. Removed by uninstall.sh.
set -euo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

DANGEROUS_PATTERNS=(
  "git[[:space:]]+push"
  "git[[:space:]]+reset[[:space:]]+--hard"
  "git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f"
  "git[[:space:]]+commit[[:space:]].*--amend"
  "git[[:space:]]+branch[[:space:]]+-D"
  "git[[:space:]]+checkout[[:space:]]+\."
  "git[[:space:]]+restore[[:space:]]+\."
  "push[[:space:]]+--force"
  "reset[[:space:]]+--hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE -- "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous git pattern '$pattern'. The user has not granted you authority to run this. If it is genuinely needed, ask the user to run it themselves." >&2
    exit 2
  fi
done

exit 0
EOF
chmod +x "$HOOK_DIR/conan-git-guardrails.sh"
```

## Step 5 — Add the git-guardrails `PreToolUse` hook

The command path contains `conan-git-guardrails`, which is the marker `uninstall.sh`
matches on.

```bash
GUARD_CMD='bash "$HOME/.claude/hooks/conan-git-guardrails.sh"'   # use the project path under project scope

jq --arg cmd "$GUARD_CMD" '
  if ([ (.hooks.PreToolUse // [])[]?.hooks[]?.command ] | any(test("conan-git-guardrails")))
  then .
  else .hooks.PreToolUse = ((.hooks.PreToolUse // []) +
        [{"matcher": "Bash", "hooks": [{"type": "command", "command": $cmd}]}])
  end
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
```

## Step 6 — Verify

```bash
# Settings now contain both hooks:
jq '.hooks' "$SETTINGS"

# Guardrails script blocks a push (expect a BLOCKED message and exit code 2):
echo '{"tool_input":{"command":"git push origin main"}}' | bash "$HOOK_DIR/conan-git-guardrails.sh"; echo "exit=$?"

# …and lets a safe command through (expect exit code 0, no output):
echo '{"tool_input":{"command":"git status"}}' | bash "$HOOK_DIR/conan-git-guardrails.sh"; echo "exit=$?"
```

## Step 7 — Confirm to the user

Report exactly what was configured:

- Scope (global or project) and the settings file path.
- caveman `SessionStart` hook added (reads `~/.claude/skills/caveman/SKILL.md` live —
  edits to the skill apply automatically, no re-run needed). It takes effect on the **next**
  session.
- git-guardrails `PreToolUse` hook added, plus the helper script path.
- To undo everything later, run `./uninstall.sh` from the repo root (use `--yes` to skip prompts).
