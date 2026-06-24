#!/usr/bin/env bash
set -euo pipefail

# Links all skills in the repository into the local skill directories used by
# each agent harness:
#   - ~/.claude/skills  — Claude Code
#   - ~/.agents/skills  — pi and other Agent-Skills-standard harnesses
# Each entry is a symlink into this repo, so a `git pull` is all that's needed
# to keep installed skills up to date.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.claude/skills"
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CAVEMAN_HOOK_MARKER="caveman-skill-autostart"
CAVEMAN_HOOK_CMD="# $CAVEMAN_HOOK_MARKER\ncat \"\$HOME/.claude/skills/caveman/SKILL.md\" | jq -Rs '{hookSpecificOutput: {hookEventName: \"SessionStart\", additionalContext: .}}'"

# If ~/.claude/skills is a symlink that resolves into this repo, we'd end up
# writing the per-skill symlinks back into the repo's own skills/ tree. Detect
# and bail out instead of polluting the working copy.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

# Remove legacy CLAUDE.md caveman block if present from older installs
CAVEMAN_MD_MARKER="# caveman-mode (managed by link-skills.sh)"
if [ -f "$GLOBAL_CLAUDE_MD" ] && grep -qF "$CAVEMAN_MD_MARKER" "$GLOBAL_CLAUDE_MD"; then
  awk '/^# caveman-mode \(managed by link-skills\.sh\)/ { skip=1; next }
       skip && /^$/ { skip=0; next }
       skip { next }
       { print }' "$GLOBAL_CLAUDE_MD" > "${GLOBAL_CLAUDE_MD}.tmp" && mv "${GLOBAL_CLAUDE_MD}.tmp" "$GLOBAL_CLAUDE_MD"
  echo "removed legacy caveman CLAUDE.md block"
fi

# Inject SessionStart hook into ~/.claude/settings.json
touch "$GLOBAL_SETTINGS"
# Initialise to empty object if file is empty or missing
if [ ! -s "$GLOBAL_SETTINGS" ] || ! jq -e . "$GLOBAL_SETTINGS" >/dev/null 2>&1; then
  echo '{}' > "$GLOBAL_SETTINGS"
fi

if jq -e '.hooks.SessionStart[]?.hooks[]?.command | select(test("caveman-skill-autostart"))' "$GLOBAL_SETTINGS" >/dev/null 2>&1; then
  echo "caveman SessionStart hook already present in $GLOBAL_SETTINGS"
else
  jq --arg cmd "$(printf '%b' "$CAVEMAN_HOOK_CMD")" '
    .hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks": [{"type": "command", "command": $cmd}]}])
  ' "$GLOBAL_SETTINGS" > "${GLOBAL_SETTINGS}.tmp" && mv "${GLOBAL_SETTINGS}.tmp" "$GLOBAL_SETTINGS"
  echo "injected caveman SessionStart hook -> $GLOBAL_SETTINGS"
fi

# Install git pre-push hook
bash "$REPO/scripts/install-hooks.sh"

find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |

while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0)

for DEST in "${DESTS[@]}"; do
  # If $DEST is a symlink that resolves into this repo, we'd end up writing the
  # per-skill symlinks back into the repo's own skills/ tree. Detect and bail
  # out instead of polluting the working copy.
  if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked $name -> $src ($DEST)"
  done
done
