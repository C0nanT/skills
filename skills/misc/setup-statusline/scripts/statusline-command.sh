#!/usr/bin/env bash
# Status line: model, context usage, git branch, cost
input=$(cat)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')

# Effort level (only present when model supports reasoning effort)
effort=$(echo "$input" | jq -r '.effort.level // empty')

# Context usage percentage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  ctx=$(printf "%.0f%%" "$used")
else
  ctx=""
fi

# Current working directory
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
[ -z "$cwd" ] && cwd="$(pwd)"

# Git branch (skip optional locks for safety)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
fi

# Session cost (from cost.total_cost_usd)
cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost_raw" ]; then
  cost=$(printf '$%.4f' "$cost_raw")
else
  cost=""
fi

# Session duration (from cost.total_duration_ms)
dur_raw=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
if [ -n "$dur_raw" ]; then
  dur_total_s=$(( ${dur_raw%.*} / 1000 ))
  dur_h=$(( dur_total_s / 3600 ))
  dur_m=$(( (dur_total_s % 3600) / 60 ))
  if [ "$dur_h" -gt 0 ]; then
    duration="${dur_h}h${dur_m}m"
  else
    duration="${dur_m}m"
  fi
else
  duration=""
fi

# 5-hour rate limit
rl_pct=""
rl_reset=""
rl_color=""
rl_pct_raw=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$rl_pct_raw" ]; then
  rl_pct=$(printf "limit:%.0f%%" "$rl_pct_raw")
  if [ -n "$rl_resets_at" ]; then
    rl_reset=$(printf '↺ %s' "$(date -d "@${rl_resets_at}" +%H:%M 2>/dev/null)")
  fi
  # Color thresholds
  rl_int=$(printf "%.0f" "$rl_pct_raw")
  if [ "$rl_int" -ge 80 ]; then
    rl_color='\033[01;31m'   # red
  elif [ "$rl_int" -ge 50 ]; then
    rl_color='\033[01;33m'   # yellow
  else
    rl_color='\033[01;32m'   # green
  fi
fi

# Build output
parts=()
if [ -n "$model" ]; then
  if [ -n "$effort" ]; then
    parts+=("$(printf '\033[01;36m%s\033[00m \033[00;36m(%s)\033[00m' "$model" "$effort")")
  else
    parts+=("$(printf '\033[01;36m%s\033[00m' "$model")")
  fi
fi
[ -n "$ctx" ]      && parts+=("$(printf '\033[01;33mctx:%s\033[00m' "$ctx")")
[ -n "$cost" ]     && parts+=("$(printf '\033[00;32m%s\033[00m' "$cost")")
[ -n "$duration" ] && parts+=("$(printf '\033[00;32m%s\033[00m' "$duration")")
if [ -n "$rl_pct" ]; then
  if [ -n "$rl_reset" ]; then
    parts+=("$(printf "${rl_color}%s %s\033[00m" "$rl_pct" "$rl_reset")")
  else
    parts+=("$(printf "${rl_color}%s\033[00m" "$rl_pct")")
  fi
fi
[ -n "$branch" ]   && parts+=("$(printf '\033[01;35m %s\033[00m' "$branch")")

if [ ${#parts[@]} -gt 0 ]; then
  # Join with separator
  result=""
  for part in "${parts[@]}"; do
    [ -n "$result" ] && result="$result $(printf '\033[02m|\033[00m') $part" || result="$part"
  done
  printf "%s" "$result"
fi
