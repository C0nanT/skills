# Guia de Skills — Índice

Documentação em português de todas as skills disponíveis.

---

## Engineering

Skills para trabalho diário de código.

| Skill | O que faz |
|-------|-----------|
| [diagnose](./diagnose.md) | Diagnóstico disciplinado de bugs: constrói loop de feedback → reproduz → hipóteses → instrumenta → corrige → teste de regressão |
| [grill-with-docs](./grill-with-docs.md) | Entrevista sobre um plano, verificando contra o glossário (`CONTEXT.md`) e ADRs do projeto. Atualiza docs inline |
| [improve-codebase-architecture](./improve-codebase-architecture.md) | Analisa a codebase em busca de módulos rasos para aprofundar. Gera relatório HTML visual com candidatos de refatoração |
| [prototype](./prototype.md) | Constrói protótipo descartável: terminal app para lógica/estado, ou variações de UI side-by-side |
| [setup-skills](./setup-skills.md) | Configura o repo para usar as skills de engenharia (issue tracker, labels de triage, layout de docs). Rodar uma vez por repo |
| [tdd](./tdd.md) | TDD com ciclo red-green-refactor. Um teste por vez, fatias verticais, sem mock de internals |
| [to-issues](./to-issues.md) | Quebra um plano/PRD em issues independentes e grabáveis no issue tracker, usando fatias verticais |
| [to-prd](./to-prd.md) | Transforma a conversa atual em um PRD estruturado e publica no issue tracker |
| [triage](./triage.md) | Gerencia o workflow de issues: avalia, reproduz bugs, cria agent briefs, aplica labels de estado |
| [zoom-out](./zoom-out.md) | Sobe um nível de abstração e mostra o mapa de módulos e callers de uma área desconhecida do código |

## Productivity

Ferramentas de workflow não específicas de código.

| Skill | O que faz |
|-------|-----------|
| [caveman](./caveman.md) | Modo de comunicação ultra-comprimido. Dropa artigos/filler/gentilezas, mantém substância técnica. Economiza ~75% tokens |
| [grill-me](./grill-me.md) | Entrevista relentless sobre um plano. Uma pergunta por vez, com resposta recomendada. Genérico, sem leitura de codebase |
| [handoff](./handoff.md) | Compacta a conversa atual em documento de handoff para outra sessão ou agente continuar o trabalho |
| [write-a-skill](./write-a-skill.md) | Cria novas skills com estrutura correta, description efetiva, e arquivos de referência separados |

## Misc

Skills mantidas mas raramente usadas.

| Skill | O que faz |
|-------|-----------|
| [git-guardrails-claude-code](./git-guardrails-claude-code.md) | Configura hooks do Claude Code para bloquear comandos git perigosos (push, reset --hard, etc.) |
| [migrate-to-shoehorn](./migrate-to-shoehorn.md) | Migra asserções `as Type` em testes TypeScript para `@total-typescript/shoehorn` |
| [scaffold-exercises](./scaffold-exercises.md) | Cria estrutura de diretórios de exercícios para cursos (específico para projetos com `ai-hero-cli`) |
| [setup-pre-commit](./setup-pre-commit.md) | Configura Husky + lint-staged + Prettier como pre-commit hooks |

---

## Workflow típico

```
1. /setup-skills          ← uma vez por repo
2. /grill-with-docs       ← antes de qualquer feature nova
3. /prototype             ← quando há dúvidas de design (opcional)
4. /to-prd                ← formaliza em PRD
5. /to-issues             ← quebra em tickets
6. /tdd                   ← implementa cada ticket
7. /diagnose              ← quando surgem bugs
8. /improve-codebase-architecture  ← periodicamente
```
