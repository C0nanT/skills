#!/usr/bin/env bash
# reset-agent-env.sh
# Reset GLOBAL agent environments — skills, hooks, rules, MCP configs — across
# Claude Code, the Agent-Skills standard dir, Cursor, Windsurf, and Antigravity.
# Use it to simulate a clean machine before testing a from-scratch install.
#
# SAFE BY DEFAULT: a dry run unless you pass --apply or --hard.
#   (no flag)        inventory only — prints what WOULD be removed, changes nothing
#   --apply          move every target into a timestamped backup dir (reversible)
#   --hard           delete every target outright (no backup)
#   --agent <name>   limit to one agent (repeatable). One of:
#                      claude | agents | cursor | windsurf | antigravity
#                    Default: all of them.
#   --yes            skip the confirmation prompt (for automation)
#   --help
#
# With --apply, backups go to ~/.cache/agent-env-reset/<timestamp>/ mirroring the
# paths under $HOME, so you can restore anything by moving it back.
#
# Coverage is COMPLETE for Claude Code and the ~/.agents/skills standard dir,
# and BEST-EFFORT for Cursor / Windsurf / Antigravity (only paths that exist are
# touched). JSON edits are surgical and need `jq`; without it they are skipped.

set -uo pipefail

# ---- args --------------------------------------------------------------------
MODE="dry"            # dry | apply | hard
ASSUME_YES=0
declare -a SELECTED=()
AGENTS_ALL=(claude agents cursor windsurf antigravity)

usage() { sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --apply) MODE="apply" ;;
    --hard)  MODE="hard" ;;
    --yes|-y) ASSUME_YES=1 ;;
    --agent) shift; [ "$#" -gt 0 ] || { echo "error: --agent needs a value" >&2; exit 1; }; SELECTED+=("$1") ;;
    --agent=*) SELECTED+=("${1#--agent=}") ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument '$1' (use --help)" >&2; exit 1 ;;
  esac
  shift
done

[ "${#SELECTED[@]}" -eq 0 ] && SELECTED=("${AGENTS_ALL[@]}")

# validate selected agents
for a in "${SELECTED[@]}"; do
  case " ${AGENTS_ALL[*]} " in *" $a "*) : ;; *) echo "error: unknown agent '$a'" >&2; exit 1 ;; esac
done

TS="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo manual)"
BACKUP_ROOT="$HOME/.cache/agent-env-reset/$TS"

# ---- target tables -----------------------------------------------------------
# Each line: kind|path|detail|description
#   dir  / file  — a directory or file to remove (detail empty)
#   jqdel        — delete a key (detail = jq path, e.g. .hooks) from a JSON file
emit_targets() {
  case "$1" in
    claude)
      echo "dir|$HOME/.claude/skills||Claude Code skills"
      echo "dir|$HOME/.claude/hooks-lib||Claude Code bundled hook scripts"
      echo "dir|$HOME/.claude/hooks||Claude Code hook helper scripts"
      echo "dir|$HOME/.claude/commands||Claude Code custom commands"
      echo "jqdel|$HOME/.claude/settings.json|.hooks|Claude Code hooks in settings.json"
      echo "jqdel|$HOME/.claude/settings.local.json|.hooks|Claude Code hooks in settings.local.json"
      echo "jqdel|$HOME/.claude.json|.mcpServers|Claude Code global MCP servers"
      echo "file|$HOME/.claude/CLAUDE.md||Claude Code global rules/memory"
      ;;
    agents)
      echo "dir|$HOME/.agents/skills||Agent-Skills standard skills dir"
      ;;
    cursor)
      echo "dir|$HOME/.cursor/rules||Cursor global rules"
      echo "file|$HOME/.cursor/mcp.json||Cursor MCP servers"
      ;;
    windsurf)
      echo "file|$HOME/.codeium/windsurf/memories/global_rules.md||Windsurf global rules"
      echo "file|$HOME/.codeium/windsurf/mcp_config.json||Windsurf MCP servers"
      ;;
    antigravity)
      echo "dir|$HOME/.antigravity||Antigravity config (best-effort)"
      echo "dir|$HOME/.config/antigravity||Antigravity config, Linux (best-effort)"
      echo "dir|$HOME/.config/Antigravity||Antigravity config, Linux (best-effort)"
      ;;
  esac
}

have_jq() { command -v jq >/dev/null 2>&1; }

target_exists() { # kind path detail
  case "$1" in
    dir|file) [ -e "$2" ] || [ -L "$2" ] ;;
    jqdel)    [ -f "$2" ] && have_jq && jq -e "($3) != null" "$2" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

# ---- removal handlers --------------------------------------------------------
remove_path() { # path
  local path="$1"
  case "$MODE" in
    apply)
      local dest="$BACKUP_ROOT/${path#"$HOME"/}"
      mkdir -p "$(dirname "$dest")"
      mv "$path" "$dest" && echo "   ✓ backed up & removed  $path"
      ;;
    hard) rm -rf "$path" && echo "   ✓ removed              $path" ;;
  esac
}

strip_json_key() { # file jqpath
  local f="$1" key="$2" tmp; tmp="$(mktemp)"
  if [ "$MODE" = "apply" ]; then
    local dest="$BACKUP_ROOT/${f#"$HOME"/}"
    mkdir -p "$(dirname "$dest")"; cp "$f" "$dest"
  fi
  if jq "del($key)" "$f" >"$tmp" 2>/dev/null; then
    mv "$tmp" "$f"
    echo "   ✓ stripped $key from   $f"
  else
    rm -f "$tmp"; echo "   ! failed to edit       $f" >&2
  fi
}

# ---- scan (inventory) --------------------------------------------------------
declare -a MATCHES=()
echo "agent-env reset — mode: $MODE — agents: ${SELECTED[*]}"
have_jq || echo "note: jq not found — JSON (.hooks / .mcpServers) steps will be skipped."

for a in "${SELECTED[@]}"; do
  printf '\n▸ %s\n' "$a"
  found=0
  while IFS='|' read -r kind path detail desc; do
    [ -n "${kind:-}" ] || continue
    if target_exists "$kind" "$path" "$detail"; then
      found=1
      printf '   • %-55s %s\n' "$path" "$desc"
      MATCHES+=("$kind|$path|$detail")
    fi
  done < <(emit_targets "$a")
  [ "$found" -eq 0 ] && echo "   (nothing found)"
done

echo
if [ "${#MATCHES[@]}" -eq 0 ]; then
  echo "Environment already clean — nothing to remove."
  exit 0
fi
echo "Found ${#MATCHES[@]} target(s)."

# ---- dry run stops here ------------------------------------------------------
if [ "$MODE" = "dry" ]; then
  echo
  echo "Dry run — nothing changed. Re-run with:"
  echo "  --apply   move the above into $HOME/.cache/agent-env-reset/<ts>/ (reversible)"
  echo "  --hard    delete the above outright"
  exit 0
fi

# ---- confirm + execute -------------------------------------------------------
if [ "$ASSUME_YES" -ne 1 ]; then
  printf '\nProceed with %s on %d target(s)? [y/N] ' "$MODE" "${#MATCHES[@]}"
  read -r reply </dev/tty 2>/dev/null || reply=""
  case "$reply" in [yY]|[yY][eE][sS]) : ;; *) echo "Aborted."; exit 1 ;; esac
fi

echo
for m in "${MATCHES[@]}"; do
  IFS='|' read -r kind path detail <<<"$m"
  case "$kind" in
    dir|file) remove_path "$path" ;;
    jqdel)    strip_json_key "$path" "$detail" ;;
  esac
done

echo
if [ "$MODE" = "apply" ]; then
  echo "Done. Backup: $BACKUP_ROOT"
  echo "Restore anything by moving it back, e.g.:  mv \"$BACKUP_ROOT/.claude/skills\" \"$HOME/.claude/skills\""
else
  echo "Done. Targets deleted (no backup)."
fi
