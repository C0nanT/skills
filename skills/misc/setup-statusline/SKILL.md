---
name: setup-statusline
description: Install a Claude Code status line
disable-model-invocation: true
---

# Setup Status Line

One-time install. Copies the bundled script and wires it into `~/.claude/settings.json`.

## Fields (left to right)

| Field | Source | Color |
| --- | --- | --- |
| Model name | `model.display_name` | bold cyan |
| Effort level | `effort.level` | dim cyan, shown in parens when present |
| Context usage | `context_window.used_percentage` + `total_input_tokens` | bold yellow, e.g. `ctx:14% 28k` |
| Session duration | `cost.total_duration_ms` | green, e.g. `23m` or `1h05m` |
| Rate limit | `rate_limits.five_hour.used_percentage` | green/yellow/red by threshold, e.g. `limit:42% ↺ 14:30` |
| Git branch | git | bold magenta, omitted outside git repos |

Rate limit color: green < 50%, yellow 50–79%, red ≥ 80%. Omitted when `rate_limits` absent.

### Reset-time timezone

The reset clock (`↺ 14:30`) is shown in the machine's local timezone. Claude Code runs the statusline with `TZ=UTC` in its environment, so the script does **not** trust the inherited `TZ` — it resolves the zone from (in order) `$STATUSLINE_TZ`, `/etc/timezone`, then the `/etc/localtime` symlink. Set `STATUSLINE_TZ` (e.g. `America/Sao_Paulo`) in `~/.claude/settings.json` `env` to override.

## Prerequisites

- `jq` installed
- `bash` (Linux — uses `date -d @EPOCH` for reset time)

## Steps

### 1. Copy the script

```bash
SRC="$HOME/.claude/skills/setup-statusline/scripts/statusline-command.sh"
# Running from repo clone instead?
#   SRC="$PWD/skills/misc/setup-statusline/scripts/statusline-command.sh"

[ -f "$SRC" ] || { echo "source script not found: $SRC"; exit 1; }
cp "$SRC" "$HOME/.claude/statusline-command.sh"
chmod +x "$HOME/.claude/statusline-command.sh"

test -x "$HOME/.claude/statusline-command.sh" \
  || { echo "copy failed"; exit 1; }
```

### 2. Copy the reset hook

```bash
SRC_RESET="$HOME/.claude/skills/setup-statusline/scripts/statusline-reset-hook.sh"
# Running from repo clone instead?
#   SRC_RESET="$PWD/skills/misc/setup-statusline/scripts/statusline-reset-hook.sh"

[ -f "$SRC_RESET" ] || { echo "source script not found: $SRC_RESET"; exit 1; }
cp "$SRC_RESET" "$HOME/.claude/statusline-reset-hook.sh"
chmod +x "$HOME/.claude/statusline-reset-hook.sh"
```

### 3. Register in settings.json

```bash
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS")"
[ -s "$SETTINGS" ] && jq -e . "$SETTINGS" >/dev/null 2>&1 || echo '{}' > "$SETTINGS"

HOOK_CMD='# claude-hook:statusline-reset
f="$HOME/.claude/statusline-reset-hook.sh"; [ -f "$f" ] && exec bash "$f"; exit 0'

jq --arg cmd "$HOOK_CMD" '
  .statusLine = {"type":"command","command":"bash ~/.claude/statusline-command.sh"}
  # Drop the old UserPromptSubmit-based reset — /clear never fires that event
  | .hooks.UserPromptSubmit = (
      (.hooks.UserPromptSubmit // [])
      | map(select((.hooks // []) | map(.command // "") | any(test("claude-hook:statusline-reset")) | not))
    )
  | if (.hooks.UserPromptSubmit | length) == 0 then del(.hooks.UserPromptSubmit) else . end
  # /clear fires SessionEnd (reason=clear) and sometimes SessionStart (source=clear)
  | .hooks.SessionEnd = (
      ((.hooks.SessionEnd // [])
        | map(select((.hooks // []) | map(.command // "") | any(test("claude-hook:statusline-reset")) | not))
      ) + [{"matcher":"clear","hooks":[{"type":"command","command":$cmd}]}]
    )
  | .hooks.SessionStart = (
      ((.hooks.SessionStart // [])
        | map(select((.hooks // []) | map(.command // "") | any(test("claude-hook:statusline-reset")) | not))
      ) + [{"matcher":"clear","hooks":[{"type":"command","command":$cmd}]}]
    )
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
```

### 4. Verify

```bash
# Should print the formatted status line (model only populated when run inside Claude):
echo '{"model":{"display_name":"Claude Sonnet 4.6"},"context_window":{"used_percentage":14}}' \
  | bash "$HOME/.claude/statusline-command.sh"
```

Takes effect at next Claude Code session start (no restart needed for mid-session updates).

## /clear behaviour

Running `/clear` resets the duration counter in the status line. `/clear` is a client-local slash command — it does **not** fire `UserPromptSubmit` — so reset uses:

1. `SessionEnd` / `SessionStart` hooks with matcher `clear` — snapshot raw cost/duration into `~/.claude/statusline-baseline.json` (cost is tracked only as a `/clear` signal; it is not displayed)
2. Fallback inside the statusline script: when `session_id` changes but cost barely moved (&lt; $0.05), treat as `/clear` and snapshot the baseline automatically
3. The statusline subtracts the duration baseline from every subsequent reading
4. If a new Claude process starts (raw cost drops below baseline), the baseline auto-clears

Context `%` + tokens come from the live window and reset naturally after `/clear`.
