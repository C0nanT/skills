# Resumo: claude-handoff

**O que faz:** resume a conversa atual em um arquivo temporário e abre um agente em segundo plano (`claude --bg`) que começa a trabalhar imediatamente a partir desse resumo. Não bloqueia a sessão: o agente aparece na lista de jobs (`claude agents`). Também inclui uma seção "suggested skills" e remove dados sensíveis.

**Quando usar:** quando você quer deixar um trabalho rodando em paralelo, sem esperar, e continuar fazendo outra coisa.

**Como invocar:** `/claude-handoff`. É uma skill só para o usuário (`disable-model-invocation: true`). Está em `in-progress/`, ou seja, é beta e ainda não faz parte do plugin.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
