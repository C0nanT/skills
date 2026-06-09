#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_DIR="$REPO/.git/hooks"
PRE_PUSH="$HOOKS_DIR/pre-push"

cat > "$PRE_PUSH" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
echo "Running skill validations before push..."
bash "$REPO/scripts/validate.sh"
EOF

chmod +x "$PRE_PUSH"
echo "pre-push hook installed at $PRE_PUSH"
