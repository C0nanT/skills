#!/usr/bin/env bash
# remove-conan-hooks.sh
# Remove os hooks que a skill `setup-conan-skills` instala:
#   - caveman      -> hook SessionStart (marcador: conan-caveman-autostart)
#   - git-guardrails -> hook PreToolUse  (script: conan-git-guardrails.sh / block-dangerous-git.sh)
#
# Uso:
#   ./remove-conan-hooks.sh            # limpa o escopo GLOBAL (~/.claude)
#   ./remove-conan-hooks.sh --project  # limpa o escopo do PROJETO (./.claude)
#   ./remove-conan-hooks.sh /caminho/.claude   # limpa um diretório .claude específico
#
# Seguro e idempotente: preserva o resto do settings.json e não falha se o hook
# não existir. Faz backup do settings antes de mexer.
set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "erro: jq não encontrado. Instale o jq primeiro." >&2; exit 1; }

# ---- resolve o diretório .claude alvo --------------------------------------
case "${1:-}" in
  ""|--global|-g) CLAUDE_DIR="$HOME/.claude" ;;
  --project|-p)   CLAUDE_DIR="$PWD/.claude" ;;
  *)              CLAUDE_DIR="${1%/}" ;;
esac

SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_DIR="$CLAUDE_DIR/hooks"

echo "Escopo: $CLAUDE_DIR"

# ---- 1/3: limpa os hooks do settings.json ----------------------------------
if [ -f "$SETTINGS" ] && jq -e . "$SETTINGS" >/dev/null 2>&1; then
  cp "$SETTINGS" "$SETTINGS.bak"

  jq '
    # remove o SessionStart do caveman (pelo marcador no comando)
    (if .hooks.SessionStart then
        .hooks.SessionStart |= map(select(
          ([.hooks[]?.command] | any(test("conan-caveman-autostart"))) | not))
     else . end)
    # remove o PreToolUse do git-guardrails (pelo nome do script)
    | (if .hooks.PreToolUse then
        .hooks.PreToolUse |= map(select(
          ([.hooks[]?.command] | any(test("conan-git-guardrails|block-dangerous-git"))) | not))
       else . end)
    # apaga chaves que ficaram vazias
    | (if (.hooks.SessionStart? == []) then del(.hooks.SessionStart) else . end)
    | (if (.hooks.PreToolUse?  == []) then del(.hooks.PreToolUse)  else . end)
    | (if (.hooks? == {}) then del(.hooks) else . end)
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

  if cmp -s "$SETTINGS" "$SETTINGS.bak"; then
    echo "  settings.json: nenhum hook do conan-skills encontrado (nada mudou)."
    rm -f "$SETTINGS.bak"
  else
    echo "  settings.json: hooks removidos. Backup em $SETTINGS.bak"
  fi
else
  echo "  settings.json: não existe ou não é JSON válido — nada a fazer."
fi

# ---- 2/3: apaga o script auxiliar do guardrails ----------------------------
removed_script=0
for s in "$HOOK_DIR/conan-git-guardrails.sh" "$HOOK_DIR/block-dangerous-git.sh"; do
  if [ -e "$s" ]; then rm -f "$s"; echo "  removido: $s"; removed_script=1; fi
done
[ "$removed_script" -eq 0 ] && echo "  hooks/: nenhum script auxiliar do guardrails encontrado."

# ---- 3/3: remove o diretório hooks se ficou vazio --------------------------
if [ -d "$HOOK_DIR" ] && [ -z "$(ls -A "$HOOK_DIR" 2>/dev/null)" ]; then
  rmdir "$HOOK_DIR" && echo "  removido diretório vazio: $HOOK_DIR"
fi

echo "Pronto."
