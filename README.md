# conan-skills

Coleção de agent skills (comandos `/slash`) para Claude Code. Fork do [repositório do Matt Pocock](https://github.com/mattpocock/skills).

## Instalar

```bash
npx skills@latest add C0nanT/skills
```

### Hooks (caveman + git guardrails)

Requer as skills instaladas. Gerenciado pelo [claude-hooks](https://github.com/C0nanT/claude-hooks):

```bash
npx @c0nant/claude-hooks install
```

Instala dois hooks no `~/.claude/settings.json`:

- **caveman** (`SessionStart`) — modo caveman automático em toda sessão
- **git-guardrails** (`PreToolUse/Bash`) — bloqueia git destrutivo antes de executar

## Desinstalar

```bash
npx @c0nant/claude-hooks uninstall
```

## Skills disponíveis

### Engineering

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[triage](./skills/engineering/triage/SKILL.md)** — Triage issues through a state machine of triage roles.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
- **[setup-skills](./skills/engineering/setup-skills/SKILL.md)** — Scaffold the per-repo config (issue tracker, triage labels, domain doc layout) that other engineering skills consume. Run once per repo.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Break any plan, spec, or PRD into independently-grabbable GitHub issues using vertical slices.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Turn the current conversation context into a PRD and submit it as a GitHub issue.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Prompt the agent to give broader context or a higher-level perspective on an unfamiliar section of code.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design.

### Productivity

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/productivity/teach/SKILL.md)** — Teach a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

### Misc

- **[git-guardrails-claude-code](./skills/misc/git-guardrails-claude-code/SKILL.md)** — Set up Claude Code hooks to block dangerous git commands before they execute.
- **[migrate-to-shoehorn](./skills/misc/migrate-to-shoehorn/SKILL.md)** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.
- **[scaffold-exercises](./skills/misc/scaffold-exercises/SKILL.md)** — Create exercise directory structures with sections, problems, solutions, and explainers.
- **[setup-pre-commit](./skills/misc/setup-pre-commit/SKILL.md)** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.
- **[setup-statusline](./skills/misc/setup-statusline/SKILL.md)** — Install a Claude Code status line showing model, context usage, session cost, rate limits, and git branch.

## Dev local

```bash
./scripts/link-skills.sh    # symlink em ~/.claude/skills
./scripts/unlink-skills.sh  # remove symlinks
./scripts/list-skills.sh    # lista todos os SKILL.md
```
