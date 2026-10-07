---
name: setup-statusline
description: Replace the old shell status line with the conan-mods plugin
disable-model-invocation: true
---

# Setup Status Line

The status line now lives in the `conan-mods` plugin (`statusline` function): model, effort, context usage, session duration, rate limit and git branch, with no bash script, `jq` or baseline file. This skill no longer installs anything. It removes the old shell-based model from the machine and points to the plugin.

## What gets removed

- `statusLine` in `~/.claude/settings.json`, only when its command points to `statusline-command.sh`.
- Hook entries carrying the marker `claude-hook:statusline-reset` under `SessionStart`, `SessionEnd` and `UserPromptSubmit`.
- `~/.claude/statusline-command.sh`, `~/.claude/statusline-reset-hook.sh` and `~/.claude/statusline-baseline.json`.

Everything else in `settings.json` stays untouched.

## Prerequisites

- `jq` installed (used only for this cleanup)

## Steps

### 1. Clean the old setup

```bash
SETTINGS="$HOME/.claude/settings.json"

if [ -s "$SETTINGS" ] && jq -e . "$SETTINGS" >/dev/null 2>&1; then
  jq '
    (if ((.statusLine.command // "") | test("statusline-command\\.sh")) then del(.statusLine) else . end)
    | reduce ("SessionStart","SessionEnd","UserPromptSubmit") as $ev (.;
        if .hooks[$ev] then
          .hooks[$ev] |= map(select((.hooks // []) | map(.command // "") | any(test("claude-hook:statusline-reset")) | not))
          | if (.hooks[$ev] | length) == 0 then del(.hooks[$ev]) else . end
        else . end)
    | if (.hooks // null) == {} then del(.hooks) else . end
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
else
  echo "settings.json missing or not valid JSON: nothing to clean"
fi

rm -f "$HOME/.claude/statusline-command.sh" \
      "$HOME/.claude/statusline-reset-hook.sh" \
      "$HOME/.claude/statusline-baseline.json"
```

### 2. Install the plugin

Tell the user to run, inside Claude Code:

```text
/plugin install conan-mods --marketplace C0nanT/claude-hooks
```

Already installed: `claude plugin update conan-mods`, then `/reload-plugins`.

### 3. Toggle

```text
/conan-mods statusline off
/conan-mods statusline on
```

The reset clock uses the machine's local timezone. If auto-detect is wrong, set `STATUSLINE_TZ` (IANA name, e.g. `America/Sao_Paulo`) in `~/.claude/settings.json` `env`.
