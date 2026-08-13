# Testing a skill locally, before pushing

When you're iterating on a skill in this clone, you don't need to push and `npx skills@latest add` on every change. Symlink the runtime location straight at the clone instead — edits land on the next invocation, no reinstall.

## Why two symlinks

`npx skills@latest` normally does two things: copies skill files into `~/.agents/skills/<skill>/` (the real directory), then symlinks `~/.claude/skills/<skill>` → `../../.agents/skills/<skill>` (what Claude Code actually reads). Reproduce the same chain, but point the first link at the repo instead of a copy:

```bash
ln -s ~/projects/claude-tools/skills/skills/<bucket>/<skill-name> ~/.agents/skills/<skill-name>
ln -s ../../.agents/skills/<skill-name> ~/.claude/skills/<skill-name>
```

Resulting chain:

```
~/.claude/skills/<skill-name>          (Claude Code reads here)
  → ~/.agents/skills/<skill-name>
    → ~/projects/claude-tools/skills/skills/<bucket>/<skill-name>   (the clone)
```

The second `ln` target is relative (`../../.agents/skills/...`) because a relative symlink target resolves from the *link's own directory*, not your shell's cwd — from inside `~/.claude/skills/`, that path lands on `~/.agents/skills/`. The first `ln` uses an absolute path, so it isn't sensitive to that.

Now `/<skill-name>` runs whatever is currently on disk in the clone (any branch, any uncommitted edit) — no reinstall between iterations.

## Removing the local link

Before switching to the real `npx` install, or just to stop shadowing it:

```bash
rm ~/.claude/skills/<skill-name> ~/.agents/skills/<skill-name>
```

`rm` on a symlink deletes the link, not its target — the repo is untouched either way.

## Switching to the real npx install

Once the skill is pushed to the remote (`git push`) and you want the actual distributed version instead of the clone:

```bash
rm ~/.claude/skills/<skill-name> ~/.agents/skills/<skill-name>
npx skills@latest add C0nanT/skills --skill=<skill-name>
```

Do the `rm` first — `npx` won't overwrite a path it doesn't recognise as its own, and a stale symlink left in place will shadow the real install.

## Where to test

Try the skill against more than one repo shape before trusting it — an empty project and a project with the specific state the skill expects to find (e.g. for `setup-devcontainer`: a repo with no Compose file, and one with an existing `compose.yaml` + override).
