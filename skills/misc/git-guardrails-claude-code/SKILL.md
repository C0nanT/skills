---
name: git-guardrails-claude-code
description: Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code.
---

# Setup Git Guardrails

Sets up a PreToolUse hook that intercepts and blocks dangerous git commands before Claude executes them.

## What Gets Blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

When blocked, Claude sees a message telling it that it does not have authority to access these commands.

This is a deterministic config task. Run the bash blocks below as written — the
copy-then-verify order matters: never register a hook that points at a script that
isn't there, or every session/Bash call will fail with
`/bin/sh: …/block-dangerous-git.sh: not found`.

## Prerequisites

- `jq` must be installed (`command -v jq`) — the merge below uses it.

## Steps

### 1. Ask scope

Ask the user: install for **this project only** (`.claude/settings.json`) or **all projects** (`~/.claude/settings.json`)?

Set the variables for the chosen scope and use them for every step:

```bash
# Global (all projects):
SETTINGS="$HOME/.claude/settings.json"
HOOK_DIR="$HOME/.claude/hooks"
HOOK_CMD='bash "$HOME/.claude/hooks/block-dangerous-git.sh"'

# Project only (instead of the three lines above):
# SETTINGS="$PWD/.claude/settings.json"
# HOOK_DIR="$PWD/.claude/hooks"
# HOOK_CMD='bash "$CLAUDE_PROJECT_DIR/.claude/hooks/block-dangerous-git.sh"'
```

### 2. Copy the hook script, then verify it landed

The bundled script is at [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh).
After an `npx skills add` install it lives at
`~/.claude/skills/git-guardrails-claude-code/scripts/block-dangerous-git.sh`.

```bash
SRC="$HOME/.claude/skills/git-guardrails-claude-code/scripts/block-dangerous-git.sh"
# Running from a clone instead of an installed skill? Point SRC at the repo copy:
#   SRC="$PWD/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh"
[ -f "$SRC" ] || { echo "source script not found: $SRC"; exit 1; }

mkdir -p "$HOOK_DIR"
cp "$SRC" "$HOOK_DIR/block-dangerous-git.sh"
chmod +x "$HOOK_DIR/block-dangerous-git.sh"

# Gate: do NOT proceed to step 3 unless the script is actually in place.
test -x "$HOOK_DIR/block-dangerous-git.sh" \
  || { echo "copy failed: $HOOK_DIR/block-dangerous-git.sh missing"; exit 1; }
```

### 3. Register the `PreToolUse` hook (idempotent jq merge)

The command is invoked through `bash` and resolves its path via `$HOME` /
`$CLAUDE_PROJECT_DIR` (never a bare `~`, which `/bin/sh` does not always expand).
The marker `block-dangerous-git` keeps the merge idempotent and lets `uninstall.sh`
find the hook later.

```bash
mkdir -p "$(dirname "$SETTINGS")"
if [ ! -s "$SETTINGS" ] || ! jq -e . "$SETTINGS" >/dev/null 2>&1; then
  echo '{}' > "$SETTINGS"
fi

jq --arg cmd "$HOOK_CMD" '
  if ([ (.hooks.PreToolUse // [])[]?.hooks[]?.command ] | any(test("block-dangerous-git")))
  then .
  else .hooks.PreToolUse = ((.hooks.PreToolUse // []) +
        [{"matcher": "Bash", "hooks": [{"type": "command", "command": $cmd}]}])
  end
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
```

### 4. Ask about customization

Ask if the user wants to add or remove any patterns from the blocked list. Edit the
copied script at `"$HOOK_DIR/block-dangerous-git.sh"` accordingly (not the bundled source).

### 5. Verify

```bash
# Blocks a push (expect a BLOCKED message and exit=2):
echo '{"tool_input":{"command":"git push origin main"}}' | bash "$HOOK_DIR/block-dangerous-git.sh"; echo "exit=$?"

# Lets a safe command through (expect exit=0, no output):
echo '{"tool_input":{"command":"git status"}}' | bash "$HOOK_DIR/block-dangerous-git.sh"; echo "exit=$?"
```
