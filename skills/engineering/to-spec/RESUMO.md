# Resumo: to-spec

**O que faz:** transforma a conversa atual e o entendimento do código em uma especificação (Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope, Further Notes) e a publica no issue tracker do projeto. Prioriza sintetizar o que já foi decidido, e só pergunta, em um lote único, sobre lacunas que não consegue preencher. Publica em markdown local (`.scratch/<feature-slug>/SPEC.md`) por padrão, ou no tracker configurado, com o rótulo `ready-for-agent`.

**Quando usar:** quando a conversa já amadureceu uma funcionalidade e você quer transformá-la em uma especificação para construir depois.

**Como invocar:** `/to-spec`. É uma skill que o agente também pode chamar sozinho (sem `disable-model-invocation`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
