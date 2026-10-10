---
"mattpocock-skills": patch
---

Narrow the `setup-skills` git guardrails seed so they stop blocking the engineering flows: `git reset` is denied only as `--hard` and `git rebase` is no longer denied, while `push`, `clean`, force deletes and discard-all commands stay denied. The `git-guardrails.md` template and the `### Git guardrails` block now say a denied command is a stop signal to report, never to route around, and list safe stand-ins (`git switch -C`, `git worktree add -b`, `git branch -d`). Projects that already hold the older broad rules keep them; `setup-skills` tells the user they can delete them by hand.
