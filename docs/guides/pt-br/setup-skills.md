# `/setup-skills` — Configuração Inicial das Skills de Engenharia

## O que é

Uma skill de configuração que prepara um repositório para usar as outras skills de engenharia. Cria arquivos de configuração que dizem ao agente onde ficam as issues, quais labels usar no triage, e onde está a documentação de domínio.

## Para que serve

- **Rodar uma vez por repo** antes de usar qualquer uma dessas skills: `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, `zoom-out`
- Quando essas skills parecem estar perdendo contexto sobre o issue tracker ou labels
- Para reconfigurar um repo que mudou de issue tracker

## Como invocar

```
/setup-skills
```

Não precisa de argumentos. A skill vai explorar o repo e conduzir a configuração.

## Como funciona

### Processo em 5 etapas

**1. Exploração** — o agente lê o repositório para entender o estado atual:
- Verifica `git remote` para identificar se é GitHub, GitLab, ou outro
- Procura `CLAUDE.md` e `AGENTS.md` para ver se já existe configuração
- Procura `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`

**2. Apresenta e pergunta** — resume o que encontrou e faz três perguntas, uma por vez, com explicação de cada uma:

**Seção A — Issue tracker**: Onde as issues vivem?
- GitHub (usa o CLI `gh`)
- GitLab (usa o CLI `glab`)
- Markdown local (arquivos em `.scratch/` — bom para projetos solo)
- Outro (Jira, Linear, etc.) — descreva o workflow

**Seção B — Labels de triage**: Quais strings você usa para os 5 estados canônicos?
- `needs-triage` — maintainer precisa avaliar
- `needs-info` — aguardando mais info do reporter
- `ready-for-agent` — completamente especificado, pronto para agente AFK
- `ready-for-human` — precisa de implementação humana
- `wontfix` — não será acionado

Se o repo já usa outras strings (ex: `bug:triage`), mapeia aqui.

**Seção C — Docs de domínio**: Layout do `CONTEXT.md` e ADRs:
- Contexto único: um `CONTEXT.md` + `docs/adr/` na raiz
- Multi-contexto: `CONTEXT-MAP.md` apontando para contextos por módulo (monorepos)

**3. Confirma** — mostra um rascunho de tudo que vai ser escrito antes de escrever.

**4. Escreve** — cria os arquivos:
- Adiciona um bloco `## Agent skills` no `CLAUDE.md` ou `AGENTS.md` (edita o que já existe, nunca cria os dois)
- Cria `docs/agents/issue-tracker.md`
- Cria `docs/agents/triage-labels.md`
- Cria `docs/agents/domain.md`

**5. Confirma conclusão** — lista quais skills agora têm o contexto necessário.

## O que é criado

```
/
├── CLAUDE.md (ou AGENTS.md)   ← bloco "## Agent skills" adicionado
└── docs/
    └── agents/
        ├── issue-tracker.md   ← onde ficam as issues e como criar
        ├── triage-labels.md   ← mapeamento das 5 labels canônicas
        └── domain.md          ← onde fica CONTEXT.md e ADRs
```

## Dicas

- Você pode editar os arquivos em `docs/agents/` manualmente depois — não precisa re-rodar a skill para pequenas mudanças
- Re-rodar é necessário só se quiser trocar de issue tracker ou recomeçar do zero
- Se o repo tem `CLAUDE.md`, o bloco vai lá. Se tem `AGENTS.md`, vai lá. Se nenhum existe, a skill pergunta qual criar
