# Resumo: diagnosing-bugs

**O que faz:** conduz uma disciplina de diagnóstico para bugs difíceis e regressões de performance, em seis fases: (1) construir um **loop de feedback** vermelho-capaz, determinístico e rápido, que reproduza o sintoma do usuário; (2) reproduzir e minimizar até o menor cenário que ainda falha; (3) formular de 3 a 5 hipóteses refutáveis; (4) instrumentar uma variável por vez, com logs marcados como `[DEBUG-...]`; (5) corrigir com teste de regressão no seam correto; (6) limpar a instrumentação e registrar a hipótese que se confirmou. Também exige redigir segredos antes de mostrar qualquer saída.

**Quando usar:** quando você diz "diagnose" ou "debug this", ou relata algo quebrado, com erro, falhando ou lento.

**Como invocar:** o agente a chama sozinho quando você relata um bug (sem `disable-model-invocation`). Você também pode pedir explicitamente com `/diagnosing-bugs`. Está em `misc/`, ou seja, é uma skill de uso raro e não faz parte do plugin.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `scripts/hitl-loop.template.sh` (template de script para loops com humano, não traduzido por ser código) e este `RESUMO.md`.
