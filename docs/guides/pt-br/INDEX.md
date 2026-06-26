# Guia de Skills — Índice

Documentação em português das skills promovidas (`engineering/`, `productivity/`, `misc/`).

---

## Engineering

Skills para trabalho diário de código.

### User-invoked

| Skill | O que faz |
|-------|-----------|
| [ask-skills](./ask-skills.md) | Roteador: indica qual skill ou fluxo usar para a sua situação |
| [grill-with-docs](./grill-with-docs.md) | Entrevista sobre um plano + atualiza `CONTEXT.md` e ADRs |
| [improve-codebase-architecture](./improve-codebase-architecture.md) | Analisa codebase em busca de módulos rasos; relatório HTML + grilling |
| [setup-skills](./setup-skills.md) | Configura issue tracker, labels de triage e layout de docs. Uma vez por repo |
| [to-issues](./to-issues.md) | Quebra plano/PRD em issues independentes (fatias verticais) |
| [to-prd](./to-prd.md) | Transforma a conversa em PRD no issue tracker |
| [prototype](./prototype.md) | Protótipo descartável: terminal app ou variações de UI |
| [implement](./implement.md) | Implementa trabalho de PRD/issues com `/tdd` e `/review` |

### Model-invoked

| Skill | O que faz |
|-------|-----------|
| [diagnosing-bugs](./diagnosing-bugs.md) | Loop de feedback → reproduz → minimiza → hipóteses → instrumenta → fix → regressão |
| [tdd](./tdd.md) | TDD red-green-refactor; fatias verticais; sem mock de internals |
| [resolving-merge-conflicts](./resolving-merge-conflicts.md) | Resolve conflitos de merge/rebase preservando intenção |

## Productivity

Ferramentas de workflow não específicas de código.

### User-invoked

| Skill | O que faz |
|-------|-----------|
| [grill-me](./grill-me.md) | Entrevista relentless (delega a `/grilling`); stateless, sem codebase |
| [handoff](./handoff.md) | Compacta conversa em documento de handoff para outra sessão |
| [writing-great-skills](./writing-great-skills.md) | Referência: vocabulário e princípios para skills previsíveis |

### Model-invoked

| Skill | O que faz |
|-------|-----------|
| [caveman](./caveman.md) | Modo de comunicação ultra-comprimido; corta artigos/filler/gentilezas, mantém substância técnica (~75% menos tokens) |
| [grilling](./grilling.md) | Entrevista uma pergunta por vez com resposta recomendada |

## Misc

Skills mantidas mas raramente usadas.

| Skill | O que faz |
|-------|-----------|
| [setup-pre-commit](./setup-pre-commit.md) | Husky + lint-staged + Prettier como pre-commit |
| [setup-statusline](./setup-statusline.md) | Status line: modelo, contexto %, custo, rate limit, branch git |
| [reset-agent-env](./reset-agent-env.md) | Limpa skills, hooks, rules e MCP globais de Claude Code, Cursor, Windsurf e Antigravity (dry-run por padrão) |

---

## Workflow típico

```
1. /setup-skills          ← uma vez por repo
2. /ask-skills            ← se não souber por onde começar
3. /grill-with-docs       ← antes de feature nova (com codebase)
4. /prototype             ← dúvidas que precisam de código (opcional)
5. /to-prd                ← formaliza em PRD (multi-sessão)
6. /to-issues             ← quebra em issues
7. /implement             ← uma issue por sessão
8. /diagnosing-bugs       ← quando surgem bugs
9. /improve-codebase-architecture  ← periodicamente
```

Issues externas entram pelo issue tracker → `/implement`.

---

## Documentação legada

Guias órfãos de skills removidas do repositório (mantidos como referência histórica):

- [zoom-out](./zoom-out.md) — mapa de módulos de alto nível (removida)
- [diagnose](./diagnose.md) — renomeada para [diagnosing-bugs](./diagnosing-bugs.md)
- [write-a-skill](./write-a-skill.md) — substituída por [writing-great-skills](./writing-great-skills.md)
