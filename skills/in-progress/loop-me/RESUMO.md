# Resumo: loop-me

**O que faz:** conduz uma sessão de grilling com estado, cujo único resultado são especificações de **fluxos de trabalho** (workflows), cada uma em `workflows/*.md`. Ela procura loops recorrentes na sua rotina que valham a pena delegar, define gatilhos, checkpoints e resumos de decisão (brief) e só termina quando um agente conseguiria implementar a especificação sem perguntar nada. As informações sobre o seu mundo ficam em `NOTES.md`.

**Quando usar:** quando você quer desenhar automações ou delegações da sua rotina (e-mails, issues, tarefas recorrentes) de forma especificada.

**Como invocar:** `/loop-me`, com um fluxo para desenhar ou sem argumento para que a skill procure um. É uma skill só para o usuário (`disable-model-invocation: true`). Está em `in-progress/`, ou seja, é beta.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
