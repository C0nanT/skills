#!/usr/bin/env bash
set -euo pipefail

# Removes symlinks created by link-skills.sh from ~/.claude/skills.
# Only removes symlinks that point into this repo; leaves anything else untouched.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.claude/skills"
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"

# Remove caveman SessionStart hook from ~/.claude/settings.json
if [ -f "$GLOBAL_SETTINGS" ] && jq -e '.hooks.SessionStart[]?.hooks[]?.command | select(test("caveman-skill-autostart"))' "$GLOBAL_SETTINGS" >/dev/null 2>&1; then
  jq '
    if .hooks.SessionStart then
      .hooks.SessionStart = [
        .hooks.SessionStart[] |
        .hooks = [.hooks[] | select(.command | test("caveman-skill-autostart") | not)] |
        select(.hooks | length > 0)
      ] |
      if (.hooks.SessionStart | length) == 0 then del(.hooks.SessionStart) else . end
    else . end
  ' "$GLOBAL_SETTINGS" > "${GLOBAL_SETTINGS}.tmp" && mv "${GLOBAL_SETTINGS}.tmp" "$GLOBAL_SETTINGS"
  echo "removed caveman SessionStart hook from $GLOBAL_SETTINGS"
fi

# Remove legacy CLAUDE.md caveman block if present from older installs
CAVEMAN_MD_MARKER="# caveman-mode (managed by link-skills.sh)"
if [ -f "$GLOBAL_CLAUDE_MD" ] && grep -qF "$CAVEMAN_MD_MARKER" "$GLOBAL_CLAUDE_MD"; then
  awk '/^# caveman-mode \(managed by link-skills\.sh\)/ { skip=1; next }
       skip && /^$/ { skip=0; next }
       skip { next }
       { print }' "$GLOBAL_CLAUDE_MD" > "${GLOBAL_CLAUDE_MD}.tmp" && mv "${GLOBAL_CLAUDE_MD}.tmp" "$GLOBAL_CLAUDE_MD"
  echo "removed legacy caveman CLAUDE.md block"
fi

if [ ! -d "$DEST" ]; then
  echo "nothing to do: $DEST does not exist"
  exit 0
fi

removed=0

find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  if [ -L "$target" ]; then
    resolved="$(readlink -f "$target")"
    if [ "$resolved" = "$src" ]; then
      rm "$target"
      echo "unlinked $name"
      removed=$((removed + 1))
    else
      echo "skip $name (symlink points elsewhere: $resolved)"
    fi
  elif [ -e "$target" ]; then
    echo "skip $name (not a symlink)"
  fi
done

echo "done"
