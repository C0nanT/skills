# Resumo: handoff

**O que faz:** cria um documento de handoff com o resumo da conversa atual, para que um agente novo continue o trabalho. O documento vai para o diretório temporário do sistema, não para o workspace, inclui uma seção "suggested skills" com as skills recomendadas ao próximo agente, faz referência a artefatos já existentes em vez de copiá-los e remove dados sensíveis.

**Quando usar:** quando você quer passar o trabalho para outra sessão ou outro agente, sem perder o contexto.

**Como invocar:** `/handoff`. É uma skill só para o usuário (`disable-model-invocation: true`). Aceita um argumento que descreve o foco da próxima sessão.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
