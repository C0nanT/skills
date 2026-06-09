# `/write-a-skill` — Create a New Skill

## What it is

A skill that helps you create new skills for Claude Code with proper structure, progressive content disclosure, and bundled resources.

## What it's for

- When you want to create a new custom skill
- When you have a repetitive process you want to turn into a skill
- To ensure the new skill has the correct structure (description, SKILL.md, reference files)

## How to invoke

```
/write-a-skill
```

## How it works

### Process

**1. Collects requirements** — asks:
- What task/domain does the skill cover?
- What specific use cases should it handle?
- Does it need executable scripts or just instructions?
- Are there reference materials to include?

**2. Drafts the skill** — creates:
- `SKILL.md` with concise instructions
- Additional reference files if content exceeds 500 lines
- Utility scripts if deterministic operations are needed

**3. Reviews with the user** — presents the draft and asks:
- Does it cover the use cases?
- Anything missing or unclear?
- Does any section need more/less detail?

### Skill structure

```
skill-name/
├── SKILL.md           ← main instructions (required)
├── REFERENCE.md       ← detailed docs (if needed)
├── EXAMPLES.md        ← usage examples (if needed)
└── scripts/           ← utility scripts (if needed)
    └── helper.js
```

### The most important part: the description

The `description` in the `SKILL.md` frontmatter is **the only thing the agent sees** when deciding which skill to load. It appears in the system prompt alongside all other installed skills.

**Good descriptions:**
- Maximum 1024 characters
- Written in the third person
- First sentence: what the skill does
- Second sentence: "Use when [specific triggers]"

```yaml
description: Disciplined bug and performance regression diagnosis. 
Use when user says "diagnose this" / "debug this", reports a bug, or describes 
a performance regression.
```

**Bad description:**
```yaml
description: Helps with debugging.
```

### When to split into multiple files

Split when:
- `SKILL.md` exceeds ~100 lines
- Content has distinct domains
- Advanced features are rarely needed

### When to add scripts

Add scripts when:
- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability vs. code generated on the fly.

### Review checklist

```
[ ] Description includes triggers ("Use when...")
[ ] SKILL.md under 100 lines
[ ] No time-sensitive information
[ ] Consistent terminology
[ ] Concrete examples included
[ ] References at most one level deep
```

## Where to place the new skill

After creating, place it in the correct bucket:
- `skills/engineering/` — daily code work
- `skills/productivity/` — non-code-specific workflow tools
- `skills/misc/` — kept around but rarely used
- `skills/personal/` — tied to your specific setup, not promoted
- `skills/in-progress/` — drafts not yet ready

Skills in `engineering/`, `productivity/`, and `misc/` need an entry in the root `README.md` and in `.claude-plugin/plugin.json`. Skills in `personal/` and `in-progress/` don't appear in either.
