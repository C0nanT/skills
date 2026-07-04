#!/usr/bin/env bash
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
README="$REPO/README.md"

PUBLIC_BUCKETS=(engineering productivity misc)
PRIVATE_BUCKETS=(personal in-progress deprecated)

errors=0
fail() { echo "  FAIL: $*" >&2; ((errors++)) || true; }
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

# ── 6. plugin.json consistency ───────────────────────────────────────────────
PLUGIN_JSON="$REPO/.claude-plugin/plugin.json"
echo ""
echo "==> plugin.json ↔ disk consistency"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  fail "$PLUGIN_JSON not found"
else
  # 6a. plugin.json → disk: every listed path must have a SKILL.md
  while IFS= read -r skill_path; do
    # paths in plugin.json are relative to the repo root (e.g. "./skills/engineering/foo")
    clean_path="${skill_path#./}"
    full_dir="$REPO/$clean_path"
    if [[ ! -d "$full_dir" ]]; then
      fail "plugin.json: $skill_path: directory not found on disk"
    elif [[ ! -f "$full_dir/SKILL.md" ]]; then
      fail "plugin.json: $skill_path: SKILL.md not found"
    else
      pass "plugin.json → disk: $skill_path"
    fi
  done < <(jq -r '.skills[]' "$PLUGIN_JSON")

  # 6b. disk → plugin.json: public skills must appear; private must not
  plugin_paths="$(jq -r '.skills[]' "$PLUGIN_JSON")"

  for bucket in "${PUBLIC_BUCKETS[@]}"; do
    bucket_dir="$SKILLS_DIR/$bucket"
    [[ -d "$bucket_dir" ]] || continue
    for skill_dir in "$bucket_dir"/*/; do
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      skill_name="$(basename "$skill_dir")"
      expected_path="./skills/$bucket/$skill_name"
      if echo "$plugin_paths" | grep -qxF "$expected_path"; then
        pass "disk → plugin.json: $bucket/$skill_name present (public)"
      else
        fail "plugin.json: missing public skill: $expected_path"
      fi
    done
  done

  for bucket in "${PRIVATE_BUCKETS[@]}"; do
    bucket_dir="$SKILLS_DIR/$bucket"
    [[ -d "$bucket_dir" ]] || continue
    for skill_dir in "$bucket_dir"/*/; do
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      skill_name="$(basename "$skill_dir")"
      expected_path="./skills/$bucket/$skill_name"
      if echo "$plugin_paths" | grep -qxF "$expected_path"; then
        fail "plugin.json: private skill must not appear: $expected_path"
      else
        pass "disk → plugin.json: $bucket/$skill_name absent (private, correct)"
      fi
    done
  done
fi

# ── 7. Bucket README ↔ disk consistency ──────────────────────────────────────
echo ""
echo "==> Bucket README.md ↔ disk consistency"
for bucket in "${PUBLIC_BUCKETS[@]}" "${PRIVATE_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  bucket_readme="$bucket_dir/README.md"
  [[ -d "$bucket_dir" ]] || continue
  [[ -f "$bucket_readme" ]] || continue  # check 5 already reports missing READMEs

  # 7a. disk → README: every SKILL.md on disk must be linked in bucket README
  for skill_dir in "$bucket_dir"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rel_link="./$skill_name/SKILL.md"
    if grep -qF "$rel_link" "$bucket_readme"; then
      pass "$bucket/README.md links $rel_link"
    else
      fail "skills/$bucket/README.md: missing link for $rel_link (skill exists on disk)"
    fi
  done

  # 7b. README → disk: every linked SKILL.md path must exist on disk
  while IFS= read -r linked; do
    # linked is like ./skill-name/SKILL.md; resolve against bucket_dir
    full_path="$bucket_dir/${linked#./}"
    if [[ -f "$full_path" ]]; then
      pass "$bucket/README.md: $linked exists on disk"
    else
      fail "skills/$bucket/README.md: links $linked but file not found on disk"
    fi
  done < <(grep -oE '\./[^/]+/SKILL\.md' "$bucket_readme" | sort -u)
done

# ── 8. Markdownlint ──────────────────────────────────────────────────────────
echo ""
echo "==> Markdownlint (SKILL.md, README.md, REFERENCE.md)"
mapfile -t _md_files < <(find "$REPO" \( -name "SKILL.md" -o -name "README.md" -o -name "REFERENCE.md" \) | sort)
if [[ ${#_md_files[@]} -gt 0 ]]; then
  _lint_errors=0
  while IFS= read -r _line; do
    [[ -z "$_line" ]] && continue
    fail "markdownlint: $_line"
    ((_lint_errors++)) || true
  done < <(npx --yes markdownlint-cli "${_md_files[@]}" 2>&1 | grep -v '^npm ' | grep -v '^$')
  [[ $_lint_errors -eq 0 ]] && pass "all markdown files"
fi

# ── Result ────────────────────────────────────────────────────────────────────
echo ""
if [[ $errors -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$errors check(s) failed." >&2
  exit 1
fi
