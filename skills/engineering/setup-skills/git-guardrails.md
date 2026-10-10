# Git guardrails

Destructive git is denied for Claude Code in this repo via `permissions.deny` in `.claude/settings.json`, not via a hook. Global hooks (if any) are separate; this file only documents the project deny list.

## Denied prefixes

- `Bash(git push *)`
- `Bash(git reset --hard *)`
- `Bash(git clean *)`
- `Bash(git -C * push)`
- `Bash(git -C * push *)`
- `Bash(git -C * reset --hard)`
- `Bash(git -C * reset --hard *)`
- `Bash(git -C * clean)`
- `Bash(git -C * clean *)`
- `Bash(git branch -D *)`
- `Bash(git branch --delete --force *)`
- `Bash(git checkout . *)`
- `Bash(git restore . *)`
- `Bash(git stash drop *)`
- `Bash(git stash clear *)`
- `Bash(git tag -d *)`
- `Bash(git tag -D *)`

Everyday git is not denied: read-only commands (`status`, `diff`, `log`, `show`, …) and the ones skills rely on (`add`, `commit`, `merge`, `rebase`, `switch`, `worktree`, `stash`, `stash create`, soft or mixed `reset`, `restore --source=<ref> --worktree -- <files>`, `branch -d`).

## When a command is denied

A denial is a stop signal. Report it to the user and wait; never route around it (no `bash -c`, no `git -C`, no `gh` or API call that does the same thing). Skills that would push, such as `/implement-spec` opening a draft PR, report the branch instead so the user pushes it. Safe stand-ins for the denied ones:

- Instead of `git reset --hard <base>`: `git switch -C <branch> <base>`, or `git worktree add -b <branch> <path> <base>`.
- Instead of `git branch -D`: `git branch -d`, which refuses an unmerged branch.

The `git -C <dir>` rules come in pairs because a trailing space-plus-`*` matches the bare command only when it is the rule's sole wildcard. Their middle `*` can span any text, so a read-only command that merely mentions a denied subcommand later on (`git -C . log --grep push`) is denied too; run it without `-C` instead.

To change the list, edit `.claude/settings.json` → `permissions.deny`.
