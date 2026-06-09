# `/git-guardrails-claude-code` — Block Dangerous Git Commands

## What it is

A skill that configures Claude Code hooks to automatically block dangerous git commands before the agent executes them.

## What it's for

- When you don't want the agent to accidentally `git push`
- To prevent the agent from resetting or deleting branches without your permission
- To add a safety layer on destructive git operations
- Especially useful in projects with production branches

## How to invoke

```
/git-guardrails-claude-code
```

## What gets blocked

- `git push` (all variations, including `--force`)
- `git reset --hard`
- `git clean -f` and `git clean -fd`
- `git branch -D`
- `git checkout .` and `git restore .`

When the agent tries to execute one of these commands, it receives a message saying it is not authorised to execute it.

## How it works

### Process

**1. Asks for scope** — install only for this project (`.claude/settings.json`) or globally for all projects (`~/.claude/settings.json`)?

**2. Copies the hook script**

Copies the bundled script to:
- **Project**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Makes the script executable with `chmod +x`.

**3. Adds the hook to settings**

The script is copied **and verified** before the hook is registered, so the
settings never point at a missing file. Adds a `PreToolUse` entry to the
corresponding settings file:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/hooks/block-dangerous-git.sh\""
          }
        ]
      }
    ]
  }
}
```

(Project scope uses `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/block-dangerous-git.sh"`.)
If the file already exists, merges without overwriting other settings.

**4. Asks about customisation** — want to add or remove patterns from the blocklist?

**5. Verifies** — runs a test to confirm the script is working:
```bash
echo '{"tool_input":{"command":"git push origin main"}}' | ./path/to/script
```
Should exit with code 2 and print a BLOCKED message.

## Usage example

```
I want to make sure Claude doesn't accidentally push in this project.

/git-guardrails-claude-code
```

The agent will ask: "Install just for this project or globally?" — you choose, it configures.

## Tips

- **Project scope** is the safer starting point — only affects the current project
- **Global scope** is convenient if you always want these guardrails across all projects
- You can edit the copied script to add/remove specific patterns manually afterwards
- The hook is a `PreToolUse` — runs *before* any Bash command the agent tries to execute
