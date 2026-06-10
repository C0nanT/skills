#!/usr/bin/env bash
# Shared helpers for the claude-hooks install/uninstall/list scripts.

# Namespace marker prefix. Every hook this tool installs carries a
# "# claude-hook:<name>" comment as the FIRST line of its command. That marker
# is what makes a hook findable and removable later without hand-editing JSON,
# and lets install be idempotent (re-running syncs instead of duplicating).
HOOK_NS="claude-hook:"

# Settings file to manage. Override with CLAUDE_SETTINGS for project-level
# hooks (.claude/settings.json) or testing. Defaults to the user-global
# Claude Code settings, which is what you usually want shared across machines.
SETTINGS_FILE="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"

# Valid Claude Code hook events. Used to catch typos in hook definitions.
VALID_EVENTS="PreToolUse PostToolUse UserPromptSubmit Notification Stop SubagentStop SessionStart SessionEnd PreCompact"

die() { echo "error: $*" >&2; exit 1; }

require_jq() {
  command -v jq >/dev/null 2>&1 || \
    die "jq is required but not installed. On Ubuntu/WSL: sudo apt-get install -y jq"
}

# Ensure the settings file exists and holds a valid JSON object.
ensure_settings() {
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  if [ ! -s "$SETTINGS_FILE" ] || ! jq -e . "$SETTINGS_FILE" >/dev/null 2>&1; then
    echo '{}' > "$SETTINGS_FILE"
  fi
}

# Atomically replace the settings file with stdin.
write_settings() {
  local tmp
  tmp="$(mktemp "${SETTINGS_FILE}.XXXXXX")"
  cat > "$tmp"
  mv "$tmp" "$SETTINGS_FILE"
}

is_valid_event() {
  case " $VALID_EVENTS " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}
