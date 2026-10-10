# Resumo: setup-skills

**O que faz:** prepara o repositório para as skills de engenharia. Define o issue tracker (markdown local por padrão, GitHub, GitLab ou outro), o vocabulário de rótulos de triagem, o layout dos documentos de domínio (`GLOSSARY.md` e ADRs, contexto único ou multi-contexto) e, opcionalmente, as regras `permissions.deny` do `.claude/settings.json` que bloqueiam git destrutivo (`push`, `reset`, `clean`, `rebase`, deleção de branches e tags). Escreve os arquivos em `docs/agents/`, faz um bloco `## Agent skills` no `CLAUDE.md` ou `AGENTS.md` e mescla as regras com backup e sem apagar configurações existentes. Não instala hooks.

**Quando usar:** uma vez por repositório, antes de usar pela primeira vez as outras skills de engenharia, como `to-spec`, `to-tickets` e `implement`.

**Como invocar:** `/setup-skills`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), os modelos-semente `issue-tracker-github`, `issue-tracker-gitlab`, `issue-tracker-local`, `triage-labels`, `domain`, `git-guardrails` (cada um em inglês e em `.pt-BR.md`) e este `RESUMO.md`.
