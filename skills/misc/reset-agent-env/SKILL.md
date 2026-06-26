---
name: reset-agent-env
description: Reset global agent environments — wipe installed skills, hooks, rules, and MCP configs across Claude Code, Cursor, Windsurf, Antigravity, and the Agent-Skills standard dir, to simulate a clean machine.
disable-model-invocation: true
---

# Reset Agent Environment

Wipe the **global** agent config on this machine — skills, hooks, rules, and MCP
servers — across every agent harness, so you can test a from-scratch install or
hand off a clean environment.

Destructive. The script defaults to a **dry run**; nothing is removed until you
confirm a mode.

## Process

### 1. Inventory (dry run)

Run the bundled script with no flags. It lists exactly what exists and would be
removed, grouped by agent — and changes nothing:

```bash
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh
```

Show the user the output.

### 2. Confirm scope and mode

Ask the user two things:

- **Which agents?** All (default), or a subset via repeatable `--agent`:
  `claude` · `agents` (the `~/.agents/skills` standard dir) · `cursor` · `windsurf` · `antigravity`.
- **Backup or hard delete?**
  - `--apply` (recommended) — moves everything into `~/.cache/agent-env-reset/<timestamp>/`, so it's reversible.
  - `--hard` — deletes outright, no backup.

### 3. Execute

Run with the chosen flags plus `--yes` (the user already confirmed):

```bash
# everything, reversible:
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --apply --yes

# scoped + hard delete:
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --hard --agent claude --agent cursor --yes
```

### 4. Report

Tell the user what was removed. For `--apply`, give the backup path and the
restore hint (move files back out of the backup dir).

This skill lives under `~/.claude/skills`, so a full Claude Code reset **removes
the skill itself** — reinstall with `npx skills@latest add C0nanT/skills` before
using it again.

## What it touches

| Agent | Targets |
| --- | --- |
| **Claude Code** | `~/.claude/skills`, `~/.claude/hooks-lib`, `~/.claude/hooks`, `~/.claude/commands`, `~/.claude/CLAUDE.md`; surgically strips `.hooks` from `settings.json` / `settings.local.json` and `.mcpServers` from `~/.claude.json` |
| **Agent-Skills standard** | `~/.agents/skills` |
| **Cursor** | `~/.cursor/rules`, `~/.cursor/mcp.json` |
| **Windsurf** | `~/.codeium/windsurf/memories/global_rules.md`, `~/.codeium/windsurf/mcp_config.json` |
| **Antigravity** | `~/.antigravity`, `~/.config/antigravity` (best-effort) |

## Notes

- Coverage is complete for **Claude Code** and the **`~/.agents/skills`** dir;
  best-effort for Cursor / Windsurf / Antigravity — only paths that already exist
  are ever touched.
- JSON edits are **surgical** — `settings.json` keeps your model, theme, and other
  preferences; only the `.hooks` key is removed.
- The JSON steps need `jq`. Without it, they're skipped with a warning (file-based
  removals still run).
- After resetting, reinstall to verify a clean setup:

  ```bash
  npx skills@latest add C0nanT/skills
  npx @c0nant/claude-hooks install
  ```
