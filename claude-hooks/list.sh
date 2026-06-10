#!/usr/bin/env bash
set -euo pipefail

# List the hooks this tool has installed in the settings file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_jq
[ -f "$SETTINGS_FILE" ] || { echo "no settings file: $SETTINGS_FILE"; exit 0; }

echo "Hooks installed by this tool in $SETTINGS_FILE:"
jq -r --arg ns "$HOOK_NS" '
  (.hooks // {}) | to_entries[] as $e
  | $e.value[]?
  | .matcher as $matcher
  | .hooks[]?
  | (.command // "") as $c
  | select($c | contains($ns))
  | ($c | split("\n")[] | select(contains($ns)) | ltrimstr("# ")) as $marker
  | "  - \($marker)  [\($e.key)\(if $matcher then " matcher=" + $matcher else "" end)]"
' "$SETTINGS_FILE" || true
