# Git guardrails

Destructive git is denied for Claude Code in this repo via `permissions.deny` in `.claude/settings.json` — not via a hook. Global hooks (if any) are separate; this file only documents the project deny list.

## Denied prefixes

- `Bash(git push *)`
- `Bash(git commit *)`
- `Bash(git reset *)`
- `Bash(git clean *)`
- `Bash(git rebase *)`
- `Bash(git branch -D *)`
- `Bash(git branch --delete --force *)`
- `Bash(git checkout . *)`
- `Bash(git restore . *)`
- `Bash(git stash drop *)`
- `Bash(git stash clear *)`
- `Bash(git tag -d *)`
- `Bash(git tag -D *)`

Read-only git (`status`, `diff`, `log`, `show`, …) is not denied.

To change the list, edit `.claude/settings.json` → `permissions.deny`.
