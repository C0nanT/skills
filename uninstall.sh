#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — removes everything the conan-skills set installs, leaving no residue.
#
# It cleans, from your GLOBAL Claude config (~/.claude):
#   1. symlinks in ~/.claude/skills/ that point into THIS repo (other repos untouched)
#   2. the caveman SessionStart + git-guardrails PreToolUse hooks that
#      /setup-conan-skills (or scripts/link-skills.sh) added to ~/.claude/settings.json
#      (other hooks untouched; the file is never deleted)
#   3. the git-guardrails helper script created by /setup-conan-skills
#
# Run it directly in your terminal, from anywhere:
#   ./uninstall.sh            # prompts before each destructive step
#   ./uninstall.sh --yes      # no prompts (for automation)
#
# Safe to run multiple times (idempotent). If a project was set up with project scope,
# remove that project's ./.claude hooks by hand — this script only touches ~/.claude.

REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
SETTINGS="$HOME/.claude/settings.json"
# Both installers' helper scripts: setup-conan-skills writes the first,
# the git-guardrails-claude-code skill writes the second.
GUARDRAILS_SCRIPTS=(
  "$HOME/.claude/hooks/conan-git-guardrails.sh"
  "$HOME/.claude/hooks/block-dangerous-git.sh"
)

# Marker used to find the hooks regardless of which installer added them.
CAVEMAN_MATCH='conan-caveman-autostart|caveman-skill-autostart|skills/caveman/SKILL.md'
GUARDRAILS_MATCH='conan-git-guardrails|block-dangerous-git'

ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help)
      sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *)
      echo "error: unknown argument '$arg' (use --yes or --help)" >&2
      exit 1 ;;
  esac
done

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  printf '%s [y/N] ' "$1"
  local reply
  read -r reply </dev/tty 2>/dev/null || { echo; return 1; }
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

echo "conan-skills uninstall — repo: $REPO"
echo

# --- 1. Remove symlinks that point into this repo -----------------------------
echo "[1/3] Symlinks in $SKILLS_DIR"
if [ -d "$SKILLS_DIR" ]; then
  found=0
  for target in "$SKILLS_DIR"/*; do
    [ -L "$target" ] || continue                 # skips the literal '*' when dir is empty
    resolved="$(readlink -f "$target" 2>/dev/null || true)"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        found=1
        if confirm "  remove symlink $(basename "$target") -> $resolved ?"; then
          rm "$target" && echo "  removed: $target"
        else
          echo "  skipped: $target"
        fi
        ;;
    esac
  done
  [ "$found" -eq 0 ] && echo "  none found (no symlinks point into this repo)"
else
  echo "  not found: $SKILLS_DIR (nothing to unlink)"
fi
echo

# --- 2. Remove hooks from settings.json ---------------------------------------
echo "[2/3] Hooks in $SETTINGS"
if [ ! -f "$SETTINGS" ]; then
  echo "  not found: $SETTINGS (nothing to clean)"
elif ! command -v jq >/dev/null 2>&1; then
  echo "  warning: 'jq' is not installed — cannot safely edit JSON." >&2
  echo "           Install jq and re-run, or remove the conan hooks from $SETTINGS by hand." >&2
else
  count="$(jq -r --arg cav "$CAVEMAN_MATCH" --arg grd "$GUARDRAILS_MATCH" '
    [ ( (.hooks.SessionStart // [])[]?.hooks[]?.command | select(test($cav)) ),
      ( (.hooks.PreToolUse  // [])[]?.hooks[]?.command | select(test($grd)) ) ] | length
  ' "$SETTINGS" 2>/dev/null || echo 0)"

  if [ "${count:-0}" -gt 0 ]; then
    if confirm "  remove $count conan hook(s) (caveman SessionStart / git-guardrails PreToolUse)?"; then
      tmp="$(mktemp)"
      jq --arg cav "$CAVEMAN_MATCH" --arg grd "$GUARDRAILS_MATCH" '
        # drop matching commands from SessionStart, then drop now-empty groups
        (if .hooks.SessionStart then
           .hooks.SessionStart |= ( [ .[]
             | .hooks |= map(select((.command // "") | test($cav) | not))
             | select((.hooks | length) > 0) ] )
         else . end)
        # same for PreToolUse
        | (if .hooks.PreToolUse then
             .hooks.PreToolUse |= ( [ .[]
               | .hooks |= map(select((.command // "") | test($grd) | not))
               | select((.hooks | length) > 0) ] )
           else . end)
        # prune empty containers so we leave no dangling keys
        | (if (.hooks.SessionStart // null) == [] then del(.hooks.SessionStart) else . end)
        | (if (.hooks.PreToolUse  // null) == [] then del(.hooks.PreToolUse)  else . end)
        | (if (.hooks // null) == {} then del(.hooks) else . end)
      ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
      echo "  removed conan hooks; preserved everything else in $SETTINGS"
    else
      echo "  skipped: $SETTINGS"
    fi
  else
    echo "  none found (no conan hooks present)"
  fi
fi
echo

# --- 3. Remove the git-guardrails helper script(s) ----------------------------
echo "[3/3] Helper scripts in $HOME/.claude/hooks"
any_found=0
for GUARDRAILS_SCRIPT in "${GUARDRAILS_SCRIPTS[@]}"; do
  [ -f "$GUARDRAILS_SCRIPT" ] || continue
  any_found=1
  if confirm "  remove $GUARDRAILS_SCRIPT ?"; then
    rm "$GUARDRAILS_SCRIPT" && echo "  removed: $GUARDRAILS_SCRIPT"
  else
    echo "  skipped: $GUARDRAILS_SCRIPT"
  fi
done
[ "$any_found" -eq 0 ] && echo "  not found (nothing to remove)"
# clean up ~/.claude/hooks only if it's now empty and we created it
rmdir "$HOME/.claude/hooks" 2>/dev/null && echo "  removed empty dir: $HOME/.claude/hooks" || true
echo

echo "Done."
