#!/usr/bin/env bash
# Fires on UserPromptSubmit — snapshots cost/duration baseline when user runs /clear
# so the statusline resets its session metrics from that point forward.
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null | tr -d '[:space:]')

if [ "$prompt" = "/clear" ]; then
  cache_file="$HOME/.claude/statusline-cache.json"
  baseline_file="$HOME/.claude/statusline-baseline.json"
  if [ -f "$cache_file" ]; then
    cp "$cache_file" "$baseline_file"
  else
    printf '{"cost_usd":0,"duration_ms":0}\n' > "$baseline_file"
  fi
fi

exit 0
