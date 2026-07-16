#!/usr/bin/env bash
# Fires on SessionEnd / SessionStart with matcher "clear".
# /clear is client-local — UserPromptSubmit never sees it — so we snapshot
# cost/duration here for the statusline to subtract from that point forward.
input=$(cat)
reason=$(echo "$input" | jq -r '.reason // .source // empty' 2>/dev/null)

# When registered with matcher "clear" this always runs for /clear; still
# accept empty reason/source for older Claude Code builds that omit the field.
if [ -n "$reason" ] && [ "$reason" != "clear" ]; then
  exit 0
fi

cache_file="$HOME/.claude/statusline-cache.json"
baseline_file="$HOME/.claude/statusline-baseline.json"
if [ -f "$cache_file" ]; then
  jq '{cost_usd: (.cost_usd // 0), duration_ms: (.duration_ms // 0)}' \
    "$cache_file" > "$baseline_file" 2>/dev/null \
    || cp "$cache_file" "$baseline_file"
else
  printf '{"cost_usd":0,"duration_ms":0}\n' > "$baseline_file"
fi

exit 0
