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
  "skills/in-progress/setup-ts-deep-modules"
  "skills/engineering/diagnosing-bugs"
  "docs/engineering/diagnosing-bugs.md"
  "docs/engineering/triage.md"
  "docs/engineering/domain-modeling.md"
  "docs/engineering/codebase-design.md"
  "docs/productivity/teach.md"
  # Upstream's own repo governance and release tooling (issue policy, triage
  # workflows, changesets release). This fork has no release pipeline.
  "SCOPE.md"
  ".out-of-scope"
  ".github/ISSUE_TEMPLATE"
  ".github/workflows/needs-info.yml"
  ".github/workflows/triage-label.yml"
  "CHANGELOG.md"
  "package.json"
  # Deleted upstream; upstream keeps an archived docs page, this fork does not.
  "docs/engineering/resolving-merge-conflicts.md"
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

echo
echo "Removing changesets upstream added (this fork cuts no release)..."
# Only files the merge added: the fork's own changesets are already in HEAD,
# and upstream's deletions of changesets it consumed are kept.
while IFS= read -r path; do
  [ -n "$path" ] || continue
  rm -f "$path"
  echo "  removed: $path"
done < <(git diff --cached --name-only --diff-filter=A HEAD -- .changeset/)

cat <<'EOF'

Next steps (not run automatically: this script never stages or commits):
  1. git status                 # see remaining conflicts and the removed paths
  2. Resolve any conflicts, then `git add` the resolutions and the removals
  3. Review with `git diff --cached`
  4. `git commit` to finish the merge
EOF
