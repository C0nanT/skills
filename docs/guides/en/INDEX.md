# Skills Guide — Index

English documentation for all available skills.

---

## Engineering

Skills for daily code work.

| Skill | What it does |
|-------|-------------|
| [diagnose](./diagnose.md) | Disciplined bug diagnosis: builds feedback loop → reproduces → hypothesises → instruments → fixes → regression test |
| [grill-with-docs](./grill-with-docs.md) | Interviews you about a plan, checking against the project glossary (`CONTEXT.md`) and ADRs. Updates docs inline |
| [improve-codebase-architecture](./improve-codebase-architecture.md) | Analyses the codebase for shallow modules to deepen. Generates a visual HTML report with refactoring candidates |
| [prototype](./prototype.md) | Builds a throwaway prototype: terminal app for logic/state, or side-by-side UI variations |
| [setup-skills](./setup-skills.md) | Configures the repo to use the engineering skills (issue tracker, triage labels, docs layout). Run once per repo |
| [tdd](./tdd.md) | TDD with red-green-refactor cycle. One test at a time, vertical slices, no mocking internals |
| [to-issues](./to-issues.md) | Breaks a plan/PRD into independent, grabbable issues on the issue tracker using vertical slices |
| [to-prd](./to-prd.md) | Turns the current conversation into a structured PRD and publishes it to the issue tracker |
| [triage](./triage.md) | Manages issue workflow: evaluates, reproduces bugs, creates agent briefs, applies state labels |
| [zoom-out](./zoom-out.md) | Steps up one abstraction level and shows the module and caller map of an unfamiliar area of the code |

## Productivity

Non-code-specific workflow tools.

| Skill | What it does |
|-------|-------------|
| [caveman](./caveman.md) | Ultra-compressed communication mode. Drops articles/filler/pleasantries, keeps technical substance. Saves ~75% tokens |
| [grill-me](./grill-me.md) | Relentless interview about a plan. One question at a time, with a recommended answer. Generic, no codebase reading |
| [handoff](./handoff.md) | Compacts the current conversation into a handoff document for another session or agent to continue the work |
| [write-a-skill](./write-a-skill.md) | Creates new skills with correct structure, effective description, and separate reference files |

## Misc

Skills kept around but rarely used.

| Skill | What it does |
|-------|-------------|
| [git-guardrails-claude-code](./git-guardrails-claude-code.md) | Configures Claude Code hooks to block dangerous git commands (push, reset --hard, etc.) |
| [migrate-to-shoehorn](./migrate-to-shoehorn.md) | Migrates `as Type` assertions in TypeScript tests to `@total-typescript/shoehorn` |
| [scaffold-exercises](./scaffold-exercises.md) | Creates exercise directory structures for courses (specific to projects using `ai-hero-cli`) |
| [setup-pre-commit](./setup-pre-commit.md) | Configures Husky + lint-staged + Prettier as pre-commit hooks |

---

## Typical workflow

```
1. /setup-skills          ← once per repo
2. /grill-with-docs       ← before any new feature
3. /prototype             ← when there are design questions (optional)
4. /to-prd                ← formalise into a PRD
5. /to-issues             ← break into tickets
6. /tdd                   ← implement each ticket
7. /diagnose              ← when bugs surface
8. /improve-codebase-architecture  ← periodically
```
