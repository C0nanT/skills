#!/usr/bin/env bash
# Status line: model, context usage (+ tokens), duration, rate limit, git branch
input=$(cat)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')

# Effort level (only present when model supports reasoning effort)
effort=$(echo "$input" | jq -r '.effort.level // empty')

# Compact token count: 850 → 850, 15500 → 15.5k, 1200000 → 1.2M
format_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) printf "%.1fM", n / 1000000
    else if (n >= 1000) {
      k = n / 1000
      if (k == int(k)) printf "%.0fk", k
      else printf "%.1fk", k
    } else printf "%.0f", n
  }'
}

# Context usage: percentage + tokens currently in the window (input-side,
# same basis as used_percentage). e.g. ctx:14% 28k
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tok_raw=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
if [ -z "$tok_raw" ] || [ "$tok_raw" = "null" ]; then
  tok_raw=$(echo "$input" | jq -r '
    (.context_window.current_usage // {}) as $u
    | ($u.input_tokens // 0)
      + ($u.cache_creation_input_tokens // 0)
      + ($u.cache_read_input_tokens // 0)
    | if . == 0 then empty else . end
  ' 2>/dev/null)
fi
ctx=""
ctx_bits=()
[ -n "$used" ] && ctx_bits+=("$(printf "%.0f%%" "$used")")
if [ -n "$tok_raw" ] && [ "$tok_raw" != "0" ]; then
  ctx_bits+=("$(format_tokens "$tok_raw")")
fi
if [ ${#ctx_bits[@]} -gt 0 ]; then
  ctx=$(IFS=' '; echo "${ctx_bits[*]}")
fi

# Current working directory
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
[ -z "$cwd" ] && cwd="$(pwd)"

# Git branch (skip optional locks for safety)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
fi

# Raw session metrics from Claude
cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
dur_raw=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

cache_file="$HOME/.claude/statusline-cache.json"
baseline_file="$HOME/.claude/statusline-baseline.json"

# Previous cache — used to detect /clear (new session_id, cost barely moved)
prev_session=""
prev_cost=0
prev_dur=0
if [ -f "$cache_file" ]; then
  prev_session=$(jq -r '.session_id // empty' "$cache_file" 2>/dev/null)
  prev_cost=$(jq -r '.cost_usd // 0' "$cache_file" 2>/dev/null)
  prev_dur=$(jq -r '.duration_ms // 0' "$cache_file" 2>/dev/null)
  [ -z "$prev_cost" ] && prev_cost=0
  [ -z "$prev_dur" ] && prev_dur=0
fi

# /clear is client-local — UserPromptSubmit never fires. session_id changes while
# process-level cost/duration keep climbing. Detect that and snapshot a baseline
# so the displayed counters reset. (Resume to another session usually jumps cost
# by more than $0.05 → we clear the baseline instead.)
if [ -n "$session_id" ] && [ -n "$prev_session" ] && [ "$session_id" != "$prev_session" ]; then
  if [ -n "$cost_raw" ]; then
    clear_like=$(awk -v c="$cost_raw" -v p="$prev_cost" 'BEGIN {
      d = c - p; if (d < 0) d = -d;
      print (d < 0.05) ? 1 : 0
    }')
    if [ "$clear_like" = "1" ]; then
      printf '{"cost_usd":%s,"duration_ms":%s}\n' \
        "${cost_raw:-0}" "${dur_raw:-0}" > "$baseline_file" 2>/dev/null || true
    else
      rm -f "$baseline_file" 2>/dev/null || true
    fi
  fi
fi

# Cache raw values (+ session_id) so SessionEnd/SessionStart clear hooks can snapshot
jq -n \
  --arg sid "$session_id" \
  --argjson cost "${cost_raw:-0}" \
  --argjson dur "${dur_raw:-0}" \
  '{session_id:$sid, cost_usd:$cost, duration_ms:$dur}' \
  > "$cache_file" 2>/dev/null || \
  printf '{"session_id":"","cost_usd":%s,"duration_ms":%s}\n' \
    "${cost_raw:-0}" "${dur_raw:-0}" > "$cache_file" 2>/dev/null || true

# Load baseline saved by /clear hook (or session_id detection above)
baseline_cost=0
baseline_dur=0
if [ -f "$baseline_file" ]; then
  b_cost=$(jq -r '.cost_usd // 0' "$baseline_file" 2>/dev/null)
  b_dur=$(jq -r '.duration_ms // 0' "$baseline_file" 2>/dev/null)
  [ -n "$b_cost" ] && baseline_cost=$b_cost
  [ -n "$b_dur" ] && baseline_dur=$b_dur
  # Auto-reset baseline when a new process started (cost dropped below baseline)
  if [ -n "$cost_raw" ] && [ "$baseline_cost" != "0" ]; then
    is_lower=$(awk "BEGIN {print ($cost_raw < $baseline_cost) ? 1 : 0}")
    if [ "$is_lower" = "1" ]; then
      rm -f "$baseline_file" 2>/dev/null || true
      baseline_cost=0
      baseline_dur=0
    fi
  fi
fi

# Session duration since last /clear (cost_raw kept only for /clear baseline detect)
duration=""
if [ -n "$dur_raw" ]; then
  dur_adj=$(( ${dur_raw%.*} - ${baseline_dur%.*} ))
  [ "$dur_adj" -lt 0 ] && dur_adj=0
  dur_total_s=$(( dur_adj / 1000 ))
  dur_h=$(( dur_total_s / 3600 ))
  dur_m=$(( (dur_total_s % 3600) / 60 ))
  if [ "$dur_h" -gt 0 ]; then
    duration="${dur_h}h${dur_m}m"
  else
    duration="${dur_m}m"
  fi
fi

# Format an epoch as HH:MM in the *machine's* local timezone.
# Claude Code runs the statusline with TZ=UTC — never trust that. Order:
#   1. $STATUSLINE_TZ override (IANA name)
#   2. host IANA zone (timedatectl / /etc/timezone / localtime symlink), skipping UTC
#   3. env -u TZ date → libc reads /etc/localtime
#   4. WSL/Windows: PowerShell local clock when Linux zone is UTC/missing
is_utc_name() {
  case "$1" in
    UTC|Etc/UTC|Etc/GMT|GMT|UCT|Universal|Zulu) return 0 ;;
    *) return 1 ;;
  esac
}

resolve_host_tz() {
  local tz=""
  if command -v timedatectl >/dev/null 2>&1; then
    tz=$(timedatectl show -p Timezone --value 2>/dev/null | tr -d '[:space:]')
    if [ -n "$tz" ] && [ "$tz" != "n/a" ] && ! is_utc_name "$tz"; then
      printf '%s' "$tz"; return
    fi
  fi
  if [ -r /etc/timezone ]; then
    tz=$(tr -d '[:space:]' < /etc/timezone)
    if [ -n "$tz" ] && ! is_utc_name "$tz"; then
      printf '%s' "$tz"; return
    fi
  fi
  if [ -L /etc/localtime ]; then
    tz=$(readlink /etc/localtime 2>/dev/null | sed 's#.*/zoneinfo/##')
    if [ -n "$tz" ] && ! is_utc_name "$tz"; then
      printf '%s' "$tz"; return
    fi
  fi
}

windows_local_hm() {
  local epoch="$1"
  command -v powershell.exe >/dev/null 2>&1 || return 1
  powershell.exe -NoProfile -Command \
    "[DateTimeOffset]::FromUnixTimeSeconds($epoch).LocalDateTime.ToString('HH:mm')" \
    2>/dev/null | tr -d '\r' | tr -d '[:space:]'
}

format_local_hm() {
  local epoch="$1" hm="" tz="" sys_off=""

  if [ -n "$STATUSLINE_TZ" ]; then
    hm=$(TZ="$STATUSLINE_TZ" date -d "@$epoch" +%H:%M 2>/dev/null) || true
    [ -n "$hm" ] && { printf '%s' "$hm"; return; }
  fi

  tz=$(resolve_host_tz)
  if [ -n "$tz" ]; then
    hm=$(TZ="$tz" date -d "@$epoch" +%H:%M 2>/dev/null) || true
    [ -n "$hm" ] && { printf '%s' "$hm"; return; }
  fi

  # Drop Claude's TZ=UTC so date uses /etc/localtime (PC zone on Ubuntu/WSL)
  hm=$(env -u TZ date -d "@$epoch" +%H:%M 2>/dev/null) || true
  sys_off=$(env -u TZ date +%z 2>/dev/null) || true
  if [ -n "$hm" ] && [ "$sys_off" != "+0000" ] && [ "$sys_off" != "-0000" ]; then
    printf '%s' "$hm"; return
  fi

  # Linux says UTC (common misconfig on WSL) or date failed → Windows clock
  win_hm=$(windows_local_hm "$epoch") || true
  if [ -n "$win_hm" ]; then
    printf '%s' "$win_hm"; return
  fi

  # Last resort: whatever we got from env -u TZ (may still be UTC)
  [ -n "$hm" ] && printf '%s' "$hm"
}

# 5-hour rate limit
rl_pct=""
rl_reset=""
rl_color=""
rl_pct_raw=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$rl_pct_raw" ]; then
  rl_pct=$(printf "limit:%.0f%%" "$rl_pct_raw")
  if [ -n "$rl_resets_at" ]; then
    hm=$(format_local_hm "$rl_resets_at")
    [ -n "$hm" ] && rl_reset=$(printf '↺ %s' "$hm")
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
