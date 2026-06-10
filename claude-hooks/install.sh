#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code hooks defined in hooks/*.json into the settings file.
#
#   ./install.sh            # install every hook in hooks/
#   ./install.sh block-rm   # install only hooks/block-rm.json
#
# Idempotent: re-running re-syncs each hook (edits to a definition are picked
# up; nothing is duplicated). Target settings file: $CLAUDE_SETTINGS or the
# user-global ~/.claude/settings.json.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
HOOKS_DIR="$SCRIPT_DIR/hooks"

require_jq
ensure_settings

install_one() {
  local file="$1" name marker event matcher command full_cmd
  name="$(basename "$file" .json)"
  marker="${HOOK_NS}${name}"

  event="$(jq -r '.event // ""' "$file")"
  matcher="$(jq -r '.matcher // ""' "$file")"
  command="$(jq -r '.command // ""' "$file")"

  [ -n "$event" ]   || die "$file: missing \"event\""
  [ -n "$command" ] || die "$file: missing \"command\""
  is_valid_event "$event" || die "$file: unknown event \"$event\" (valid: $VALID_EVENTS)"

  # Prepend the marker comment so the hook can be found/removed later.
  full_cmd="$(printf '# %s\n%s' "$marker" "$command")"

  # Upsert: strip any existing copy of this marker (across the target event),
  # then append the fresh group. Keeps the installed hook in sync with the file.
  jq \
    --arg ev "$event" \
    --arg matcher "$matcher" \
    --arg cmd "$full_cmd" \
    --arg m "$marker" '
    (if $matcher == ""
       then {hooks: [{type: "command", command: $cmd}]}
       else {matcher: $matcher, hooks: [{type: "command", command: $cmd}]}
     end) as $group
    | .hooks[$ev] = [ ((.hooks[$ev] // [])[])
        | .hooks = [ .hooks[] | select((.command // "") | contains($m) | not) ]
        | select((.hooks | length) > 0) ]
    | .hooks[$ev] += [ $group ]
  ' "$SETTINGS_FILE" | write_settings

  echo "installed $name -> $event${matcher:+ (matcher: $matcher)}"
}

main() {
  local targets=()
  if [ "$#" -gt 0 ]; then
    local n
    for n in "$@"; do targets+=("$HOOKS_DIR/${n%.json}.json"); done
  else
    shopt -s nullglob
    targets=("$HOOKS_DIR"/*.json)
    shopt -u nullglob
  fi
  [ "${#targets[@]}" -gt 0 ] || die "no hook definitions found in $HOOKS_DIR"

  local f
  for f in "${targets[@]}"; do
    [ -f "$f" ] || die "no such hook definition: $f"
    install_one "$f"
  done
  echo "done -> $SETTINGS_FILE"
}

main "$@"
