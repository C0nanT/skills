# conan-skills

Coleção de agent skills (comandos `/slash`) para Claude Code e outros coding agents. Cada skill é um arquivo markdown (`SKILL.md`) que o agente lê na hora da invocação.

Fork do [repositório original do Matt Pocock](https://github.com/mattpocock/skills), adaptado e mantido por [Conan Torres](https://github.com/C0nanT).

## O que é isso

Skills pequenas, composáveis e fáceis de adaptar — pensadas para engenharia de verdade, não vibe coding. Cobrem alinhamento antes de codar (`/grill-me`, `/grill-with-docs`), feedback loops (`/tdd`, `/diagnose`), fluxo de issues (`/to-prd`, `/to-issues`, `/triage`), arquitetura (`/improve-codebase-architecture`, `/zoom-out`) e produtividade geral (`/caveman`, `/handoff`).

Funcionam com qualquer modelo. Instale só o que precisar.

## Instalação

> **Use um terminal externo** (Terminal.app, iTerm, GNOME Terminal, etc.) — **não** o terminal integrado da IDE. O instalador é interativo: em terminais de IDE o menu de seleção pode não funcionar e todas as skills podem ser instaladas de uma vez, sem você escolher.

```bash
npx skills@latest add C0nanT/skills
```

O instalador pergunta quais skills instalar e em quais agents. **Selecione pelo menos:**

- `/setup-skills` — configura issue tracker, labels de triagem e layout de docs no repositório

Depois, no agent:

1. Rode `/setup-skills` uma vez por repositório de projeto.

### Hooks (caveman automático + git guardrails)

Os hooks do Claude Code são gerenciados pelo **[claude-hooks](https://github.com/C0nanT/claude-hooks)** — um projeto separado instalável via npx:

```bash
npx claude-hooks@latest install
```

Isso instala dois hooks no `~/.claude/settings.json` global:

- **caveman** (`SessionStart`) — injeta o modo caveman automaticamente em toda sessão
- **git-guardrails** (`PreToolUse/Bash`) — bloqueia comandos git destrutivos antes do agente executar

Para desinstalar os hooks:

```bash
npx claude-hooks@latest uninstall
```

## Desenvolvimento local

Se você está editando skills neste repositório:

```bash
./scripts/link-skills.sh    # symlink em ~/.claude/skills + hook caveman
./scripts/unlink-skills.sh  # remove os symlinks do repo
./scripts/list-skills.sh    # lista todos os SKILL.md
```

## Skills disponíveis

### Engineering

Skills para trabalho com código.

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[triage](./skills/engineering/triage/SKILL.md)** — Triage issues through a state machine of triage roles.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
- **[setup-skills](./skills/engineering/setup-skills/SKILL.md)** — Scaffold the per-repo config (issue tracker, triage label vocabulary, domain doc layout) that the other engineering skills consume. Run once per repo before using `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, or `zoom-out`.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Break any plan, spec, or PRD into independently-grabbable GitHub issues using vertical slices.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Turn the current conversation context into a PRD and submit it as a GitHub issue. No interview — just synthesizes what you've already discussed.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design — either a runnable terminal app for state/business-logic questions, or several radically different UI variations toggleable from one route.

### Productivity

Ferramentas de workflow geral, sem foco em código.

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/productivity/teach/SKILL.md)** — Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

### Misc

Ferramentas úteis, mas usadas com menos frequência.

- **[git-guardrails-claude-code](./skills/misc/git-guardrails-claude-code/SKILL.md)** — Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, etc.) before they execute.
- **[migrate-to-shoehorn](./skills/misc/migrate-to-shoehorn/SKILL.md)** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.
- **[scaffold-exercises](./skills/misc/scaffold-exercises/SKILL.md)** — Create exercise directory structures with sections, problems, solutions, and explainers.
- **[setup-pre-commit](./skills/misc/setup-pre-commit/SKILL.md)** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.
