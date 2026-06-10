#!/usr/bin/env bash
set -euo pipefail

# Remove Claude Code hooks installed by this tool from the settings file.
#
#   ./uninstall.sh            # remove ALL hooks installed by this tool
#   ./uninstall.sh block-rm   # remove only the block-rm hook
#
# Surgical: only touches hooks carrying this tool's "claude-hook:" marker;
# anything else in your settings.json is left untouched. Emptied groups,
# events, and the hooks object are pruned so nothing dangling is left behind.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_jq
[ -f "$SETTINGS_FILE" ] || { echo "nothing to do: $SETTINGS_FILE does not exist"; exit 0; }
ensure_settings

# Remove every hook whose command contains $marker, across all events.
remove_marker() {
  local marker="$1"
  jq --arg m "$marker" '
    if .hooks then
      .hooks |= (
        to_entries
        | map(.value |= [ .[]
            | .hooks = [ .hooks[] | select((.command // "") | contains($m) | not) ]
            | select((.hooks | length) > 0) ])
        | map(select((.value | length) > 0))
        | from_entries
      )
      | if (.hooks | length) == 0 then del(.hooks) else . end
    else . end
  ' "$SETTINGS_FILE" | write_settings
}

main() {
  local before after
  before="$(jq -S . "$SETTINGS_FILE")"

  if [ "$#" -gt 0 ]; then
    local n
    for n in "$@"; do remove_marker "${HOOK_NS}${n%.json}"; done
  else
    # No args: remove the whole namespace (every hook this tool ever installed,
    # including ones whose definition file was since deleted).
    remove_marker "$HOOK_NS"
  fi

  after="$(jq -S . "$SETTINGS_FILE")"
  if [ "$before" = "$after" ]; then
    echo "no matching hooks found in $SETTINGS_FILE"
  else
    echo "removed hooks from $SETTINGS_FILE"
  fi
}

main "$@"
