#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
README="$REPO/README.md"

PUBLIC_BUCKETS=(engineering productivity misc)
PRIVATE_BUCKETS=(personal in-progress deprecated)

errors=0
fail() { echo "  FAIL: $*" >&2; ((errors++)); }
pass() { echo "  ok:   $*"; }

# ── 1. Frontmatter ────────────────────────────────────────────────────────────
echo "==> Frontmatter (name + description required)"
while IFS= read -r skill_file; do
  rel="${skill_file#"$REPO/"}"
  has_name=$(grep -m1 '^name:' "$skill_file" || true)
  has_desc=$(grep -m1 '^description' "$skill_file" || true)
  if [[ -z "$has_name" || -z "$has_desc" ]]; then
    fail "$rel missing name or description in frontmatter"
  else
    pass "$rel"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" | sort)

# ── 2. Public skills listed in root README ────────────────────────────────────
echo ""
echo "==> Public skills referenced in root README.md"
for bucket in "${PUBLIC_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  [[ -d "$bucket_dir" ]] || continue
  for skill_dir in "$bucket_dir"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rel_path="skills/$bucket/$skill_name/SKILL.md"
    if grep -qF "$rel_path" "$README"; then
      pass "$bucket/$skill_name in README"
    else
      fail "$bucket/$skill_name not referenced in README (expected path: $rel_path)"
    fi
  done
done

# ── 3. Private skills NOT in root README ─────────────────────────────────────
echo ""
echo "==> Private skills absent from root README.md"
for bucket in "${PRIVATE_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  [[ -d "$bucket_dir" ]] || continue
  for skill_dir in "$bucket_dir"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rel_path="skills/$bucket/$skill_name/SKILL.md"
    if grep -qF "$rel_path" "$README"; then
      fail "$bucket/$skill_name is private but appears in README"
    else
      pass "$bucket/$skill_name not in README (correct)"
    fi
  done
done

# ── 4. README links point to existing files ───────────────────────────────────
echo ""
echo "==> README links resolve to existing files"
while IFS= read -r link_path; do
  full_path="$REPO/$link_path"
  if [[ -f "$full_path" ]]; then
    pass "$link_path"
  else
    fail "$link_path linked in README but file not found"
  fi
done < <(grep -oE 'skills/[^)]+/SKILL\.md' "$README" | sort -u)

# ── 5. Bucket READMEs exist ───────────────────────────────────────────────────
echo ""
echo "==> Bucket README.md files exist"
for bucket in "${PUBLIC_BUCKETS[@]}" "${PRIVATE_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  [[ -d "$bucket_dir" ]] || continue
  if [[ -f "$bucket_dir/README.md" ]]; then
    pass "$bucket/README.md"
  else
    fail "$bucket/README.md missing"
  fi
done

# ── Result ────────────────────────────────────────────────────────────────────
echo ""
if [[ $errors -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$errors check(s) failed." >&2
  exit 1
fi
