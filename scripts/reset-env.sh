#!/usr/bin/env bash
set -euo pipefail

echo "==> Removing claude-hooks from settings.json..."
if command -v npx &>/dev/null; then
  npx @c0nant/claude-hooks uninstall 2>/dev/null || true
else
  echo "    npx not found, skipping hook uninstall"
fi

echo "==> Removing installed skills..."
rm -rf "$HOME/.agents/skills"
rm -rf "$HOME/.claude/skills"

echo ""
echo "Clean. To reinstall from scratch:"
echo ""
echo "  npx skills@latest add C0nanT/skills"
echo "  npx @c0nant/claude-hooks install"
echo ""
