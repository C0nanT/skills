#!/usr/bin/env bash
set -euo pipefail

# Merges mattpocock/skills (the "upstream" remote) into the current branch,
# then strips out the skills below that this fork deliberately does not carry.
# Add a path here whenever you decide a new upstream skill isn't wanted, so
# future merges drop it automatically instead of requiring a manual re-delete.
#
# Paths are relative to the repo root and may be files or directories.
EXCLUDED_PATHS=(
  "skills/engineering/triage"
  "skills/engineering/domain-modeling"
  "skills/engineering/codebase-design"
  "skills/productivity/teach"
  "skills/misc/git-guardrails-claude-code"
  "skills/misc/migrate-to-shoehorn"
  "skills/misc/scaffold-exercises"
  "skills/personal/edit-article"
  "skills/personal/obsidian-vault"
  "docs/engineering/triage.md"
  "docs/engineering/domain-modeling.md"
  "docs/engineering/codebase-design.md"
  "docs/productivity/teach.md"
)

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

git fetch upstream

echo "Merging upstream/main into $(git branch --show-current)..."
git merge upstream/main --no-commit --no-ff || true

echo
echo "Removing excluded upstream-only paths..."
for path in "${EXCLUDED_PATHS[@]}"; do
  if [ -e "$path" ]; then
    rm -rf "$path"
    echo "  removed: $path"
  fi
done

cat <<'EOF'

Next steps (not run automatically — this script never stages or commits):
  1. git status                 # see remaining conflicts and the removed paths
  2. Resolve any conflicts, then `git add` the resolutions and the removals
  3. Review with `git diff --cached`
  4. `git commit` to finish the merge
EOF
