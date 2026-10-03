#!/usr/bin/env bash
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
README="$REPO/README.md"

PUBLIC_BUCKETS=(engineering productivity misc)
PRIVATE_BUCKETS=(personal in-progress deprecated)

# Finished skills that stay in a public bucket but are not shipped in the
# plugin or the top-level README. Install with --skill=<name>.
UNPROMOTED_SKILLS=(setup-pre-commit reset-agent-env diagnosing-bugs)

is_unpromoted() {
  local name="$1"
  local s
  for s in "${UNPROMOTED_SKILLS[@]}"; do
    [[ "$s" == "$name" ]] && return 0
  done
  return 1
}

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
    if is_unpromoted "$skill_name"; then
      if grep -qF "$rel_path" "$README"; then
        fail "$bucket/$skill_name is unpromoted but appears in README"
      else
        pass "$bucket/$skill_name not in README (unpromoted, correct)"
      fi
    elif grep -qF "$rel_path" "$README"; then
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
      if is_unpromoted "$skill_name"; then
        if echo "$plugin_paths" | grep -qxF "$expected_path"; then
          fail "plugin.json: unpromoted skill must not appear: $expected_path"
        else
          pass "disk → plugin.json: $bucket/$skill_name absent (unpromoted, correct)"
        fi
      elif echo "$plugin_paths" | grep -qxF "$expected_path"; then
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

# ── 9. Invocation mode ───────────────────────────────────────────────────────
# A skill is user-invoked in both harnesses or neither: SKILL.md carries
# `disable-model-invocation: true` exactly when agents/openai.yaml carries
# `allow_implicit_invocation: false`. Every skill has an openai.yaml, and a
# `Skill tool ... "name"` call must name a skill that exists and is model-invoked.
echo ""
echo "==> Invocation mode (SKILL.md ↔ openai.yaml, Skill tool targets)"
declare -A user_invoked=()
declare -A skill_exists=()
while IFS= read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  rel="${skill_file#"$REPO/"}"
  skill_exists[$skill_name]=1
  yaml="$skill_dir/agents/openai.yaml"
  md_user=0; yaml_user=0
  # Only the frontmatter block (up to the second ---) counts.
  if awk 'NR==1 {next} $0=="---" {exit} /^disable-model-invocation: true$/ {f=1} END {exit !f}' "$skill_file"; then
    md_user=1
  fi
  [[ $md_user -eq 1 ]] && user_invoked[$skill_name]=1
  if [[ ! -f "$yaml" ]]; then
    fail "$rel: agents/openai.yaml missing"
    continue
  fi
  grep -qE '^[[:space:]]+allow_implicit_invocation: false$' "$yaml" && yaml_user=1
  if [[ $md_user -ne $yaml_user ]]; then
    fail "$rel: invocation mode differs (SKILL.md user-invoked=$md_user, openai.yaml user-invoked=$yaml_user)"
  else
    pass "$rel: invocation mode consistent"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" | sort)

while IFS= read -r skill_file; do
  rel="${skill_file#"$REPO/"}"
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    if [[ -z "${skill_exists[$target]:-}" ]]; then
      fail "$rel: Skill tool call names \"$target\", which does not exist"
    elif [[ -n "${user_invoked[$target]:-}" ]]; then
      fail "$rel: Skill tool call names \"$target\", which is user-invoked"
    else
      pass "$rel: Skill tool call to $target"
    fi
  done < <(grep -oE 'Skill tool[^."]*("[a-z][a-z0-9-]*"( and )?)+' "$skill_file" | grep -oE '"[a-z][a-z0-9-]*"' | tr -d '"' | sort -u)
done < <(find "$SKILLS_DIR" -name "SKILL.md" | sort)

# ── 10. setup-skills settings merge snippet ───────────────────────────────────
# Extracts the bash block that starts with the marker comment below, plus the
# `text` deny list right before it, and runs the snippet against throwaway
# settings files. CLAUDE_PROJECT_DIR is pinned to the temp dir on every run so
# a session's own project settings are never touched.
echo ""
echo "==> setup-skills settings merge snippet"
SETUP_SKILL="$SKILLS_DIR/engineering/setup-skills/SKILL.md"
MERGE_MARKER="# setup-skills: merge git deny rules"
_merge_tmp="$(mktemp -d)"
trap 'rm -rf "$_merge_tmp"' EXIT

awk -v marker="$MERGE_MARKER" '
  /^```bash$/ { getline first; if (first == marker) { grab = 1; print first }; next }
  grab && /^```$/ { exit }
  grab { print }
' "$SETUP_SKILL" > "$_merge_tmp/snippet.sh"

# The deny list text block is the last ```text block before the snippet.
awk -v marker="$MERGE_MARKER" '
  /^```text$/ { inblock = 1; n = 0; next }
  inblock && /^```$/ { inblock = 0; next }
  inblock { lines[++n] = $0; next }
  $0 == marker { for (i = 1; i <= n; i++) print lines[i]; exit }
' "$SETUP_SKILL" > "$_merge_tmp/deny-list.txt"

run_merge() { # $1 = project dir, $2 = PATH for the run
  env PATH="$2" CLAUDE_PROJECT_DIR="$1" "$bash_bin" "$_merge_tmp/snippet.sh" \
    > "$1/out.log" 2>&1
}

if [[ ! -s "$_merge_tmp/snippet.sh" ]]; then
  fail "setup-skills: merge snippet not found (marker: $MERGE_MARKER)"
elif [[ ! -s "$_merge_tmp/deny-list.txt" ]]; then
  fail "setup-skills: deny list text block not found before the merge snippet"
else
  bash_bin="$(command -v bash)"
  # Every `git <cmd> *` rule for these five must have both -C shapes.
  for cmd in push commit reset clean rebase; do
    for rule in "Bash(git -C * $cmd)" "Bash(git -C * $cmd *)"; do
      if grep -qxF "$rule" "$_merge_tmp/deny-list.txt"; then
        pass "setup-skills deny list has $rule"
      else
        fail "setup-skills deny list missing $rule"
      fi
    done
  done

  # a. No jq on PATH: exits non-zero, existing file byte-identical.
  d="$_merge_tmp/nojq"; mkdir -p "$d/.claude" "$d/bin"
  echo '{"permissions":{"allow":["Bash(ls *)"]}}' > "$d/.claude/settings.json"
  cp "$d/.claude/settings.json" "$d/orig.json"
  if env PATH="$d/bin" CLAUDE_PROJECT_DIR="$d" "$bash_bin" "$_merge_tmp/snippet.sh" > "$d/out.log" 2>&1; then
    fail "setup-skills merge: exited 0 without jq"
  elif ! cmp -s "$d/orig.json" "$d/.claude/settings.json"; then
    fail "setup-skills merge: settings.json changed without jq"
  else
    pass "setup-skills merge: stops without jq, file untouched"
  fi

  # b. Invalid JSON: exits non-zero, prints an error, file untouched.
  d="$_merge_tmp/invalid"; mkdir -p "$d/.claude"
  printf '{ "permissions": { "allow": [ "Bash(ls *)" ' > "$d/.claude/settings.json"
  cp "$d/.claude/settings.json" "$d/orig.json"
  if run_merge "$d" "$PATH"; then
    fail "setup-skills merge: exited 0 on invalid JSON"
  elif ! cmp -s "$d/orig.json" "$d/.claude/settings.json"; then
    fail "setup-skills merge: invalid settings.json was modified"
  elif [[ ! -s "$d/out.log" ]]; then
    fail "setup-skills merge: no error shown on invalid JSON"
  elif compgen -G "$d/.claude/settings.json.*" > /dev/null; then
    fail "setup-skills merge: left temp or backup files on invalid JSON"
  else
    pass "setup-skills merge: stops on invalid JSON, file untouched"
  fi

  # c. Valid settings: allow/hooks/env/existing deny kept, rules appended, backup made.
  d="$_merge_tmp/valid"; mkdir -p "$d/.claude"
  cat > "$d/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": ["Bash(npm test *)", "Read(./src/**)"],
    "deny": ["Read(./.env)"]
  },
  "hooks": {"PostToolUse": [{"matcher": "Edit", "hooks": [{"type": "command", "command": "echo hi"}]}]},
  "env": {"FOO": "bar"}
}
JSON
  cp "$d/.claude/settings.json" "$d/orig.json"
  if ! run_merge "$d" "$PATH"; then
    fail "setup-skills merge: failed on valid settings: $(cat "$d/out.log")"
  else
    s="$d/.claude/settings.json"
    if jq -e --slurpfile o "$d/orig.json" '
        .permissions.allow == $o[0].permissions.allow
        and .hooks == $o[0].hooks and .env == $o[0].env
        and .permissions.deny[0] == "Read(./.env)"' "$s" > /dev/null; then
      pass "setup-skills merge: allow rules, hooks, env and existing deny kept"
    else
      fail "setup-skills merge: existing settings not preserved"
    fi
    missing="$(jq -r --rawfile want "$_merge_tmp/deny-list.txt" '
        .permissions.deny as $d
        | $want | split("\n") | map(select(length > 0))
        | map(select(. as $r | $d | index([$r]) | not)) | .[]' "$s")"
    if [[ -z "$missing" ]]; then
      pass "setup-skills merge: every rule of the text list is in deny (lists in sync)"
    else
      fail "setup-skills merge: rules in the text list missing after merge: $missing"
    fi
    backups=("$d/.claude/settings.json.bak-"*)
    if [[ ${#backups[@]} -eq 1 && -f "${backups[0]}" ]] && cmp -s "${backups[0]}" "$d/orig.json"; then
      pass "setup-skills merge: backup equals the previous file"
    else
      fail "setup-skills merge: expected one backup identical to the previous file"
    fi

    # d. Second run: no duplicates, no change, no new backup.
    cp "$s" "$d/after1.json"
    if run_merge "$d" "$PATH" && cmp -s "$s" "$d/after1.json" \
        && jq -e '(.permissions.deny | length) == (.permissions.deny | unique | length)' "$s" > /dev/null \
        && [[ $(compgen -G "$d/.claude/settings.json.bak-*" | wc -l) -eq 1 ]]; then
      pass "setup-skills merge: second run is a no-op, no duplicates"
    else
      fail "setup-skills merge: second run changed the file or duplicated rules"
    fi
  fi

  # e. Missing file and empty file: created with the deny rules.
  for case in missing empty; do
    d="$_merge_tmp/$case"; mkdir -p "$d"
    if [[ "$case" == empty ]]; then mkdir -p "$d/.claude"; : > "$d/.claude/settings.json"; fi
    want="$(grep -c . "$_merge_tmp/deny-list.txt")"
    if run_merge "$d" "$PATH" \
        && jq -e --argjson n "$want" '(.permissions.deny | length) == $n' "$d/.claude/settings.json" > /dev/null; then
      pass "setup-skills merge: $case settings.json created with the deny rules"
    else
      fail "setup-skills merge: $case settings.json not created with the deny rules"
    fi
  done
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
