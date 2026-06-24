# `/reset-agent-env` — Reset Global Agent Environments

## What it is

A user-invoked maintenance skill that wipes the **global** agent config on this
machine — installed skills, hooks, rules, and MCP servers — across every agent
harness. Use it to simulate a clean machine before testing a from-scratch install.

It's destructive, so the bundled script defaults to a **dry run**: it prints what
would be removed and changes nothing until you pick a mode.

## What it's for

- Simulating a fresh PC to verify that `npx skills add` / `npx @c0nant/claude-hooks install` work end to end
- Clearing cross-tool residue left behind by partial uninstalls
- Handing off a clean environment

## How to invoke

```
/reset-agent-env
```

## How it works

1. **Inventory (dry run)** — runs the bundled script with no flags and shows you,
   grouped by agent, exactly which paths exist and would be removed. Nothing changes.
2. **Confirm scope and mode** — you choose which agents and whether to back up or
   hard-delete.
3. **Execute** — runs the script with your flags.
4. **Report** — lists what was removed and, for `--apply`, the backup path.

## Modes and flags

| Flag | Effect |
|------|--------|
| *(none)* | Dry run — inventory only, nothing removed |
| `--apply` | Moves targets into `~/.cache/agent-env-reset/<timestamp>/` (reversible) |
| `--hard` | Deletes targets outright (no backup) |
| `--agent <name>` | Limit to one agent (repeatable): `claude` · `agents` · `cursor` · `windsurf` · `antigravity` |
| `--yes` | Skip the confirmation prompt |

```bash
# inventory (safe)
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh
# wipe everything, reversible
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --apply --yes
# scoped, hard delete
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --hard --agent claude --agent cursor --yes
```

## What it touches

| Agent | Targets |
|-------|---------|
| **Claude Code** | `~/.claude/skills`, `~/.claude/hooks-lib`, `~/.claude/hooks`, `~/.claude/commands`, `~/.claude/CLAUDE.md`; strips `.hooks` from `settings.json` / `settings.local.json` and `.mcpServers` from `~/.claude.json` |
| **Agent-Skills standard** | `~/.agents/skills` |
| **Cursor** | `~/.cursor/rules`, `~/.cursor/mcp.json` |
| **Windsurf** | `~/.codeium/windsurf/memories/global_rules.md`, `~/.codeium/windsurf/mcp_config.json` |
| **Antigravity** | `~/.antigravity`, `~/.config/antigravity` (best-effort) |

## Notes

- Coverage is complete for **Claude Code** and the **`~/.agents/skills`** dir;
  best-effort for Cursor / Windsurf / Antigravity — only existing paths are touched.
- JSON edits are surgical (`del(.hooks)`, `del(.mcpServers)`) — model, theme, and
  other preferences in `settings.json` are preserved. These steps need `jq`.
- The skill lives under `~/.claude/skills`, so a full Claude Code reset **removes
  the skill itself** — reinstall with `npx skills@latest add C0nanT/skills` after.
- Reinstall to verify a clean setup:
  ```bash
  npx skills@latest add C0nanT/skills
  npx @c0nant/claude-hooks install
  ```
