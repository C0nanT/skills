# 01: Hook allows commit

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** `../SPEC.md`

**What to build:** in the `claude-hooks` repo, the `git-guardrails` hook stops blocking `git commit` in every form (bare, with `-c k=v`, with `-C <dir>`) and stops blocking read-only commands that merely contain the pattern (a `grep` for it). Every other dangerous pattern stays blocked. The release goes out as a minor bump (`feat(git-guardrails):` prefix, no `!`).

**Seams:**
- `claude-hooks/test/run.sh`, `git-guardrails` sections (`assert_blocked` / `assert_allowed`)

**Blocked by:** None (can start immediately)

Status: ready-for-agent

- [ ] `git commit -m x` is `assert_allowed` in the suite
- [ ] `git -c user.email=x -c user.name=y commit -m x` is `assert_allowed`
- [ ] `git -C /tmp commit -m x` is `assert_allowed` (new assertion)
- [ ] A `grep` whose pattern contains "git commit" is `assert_allowed` (new assertion)
- [ ] push, reset --hard, rm, `-C dir push`, `--no-pager reset --hard` and `--git-dir push` stay `assert_blocked`
- [ ] `bash test/run.sh` passes
- [ ] The `claude-hooks` README (hooks table) and the hooks table in the `skills` README describe exactly the patterns still blocked
- [ ] The final report reminds the user to reinstall the hook after the release to update the copy in `~/.claude/hooks-lib/`
