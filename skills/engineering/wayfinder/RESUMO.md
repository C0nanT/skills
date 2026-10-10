# Resumo: wayfinder

**O que faz:** planeja um trabalho grande demais para uma sessão de agente. Cria um **mapa** (uma issue `wayfinder:map` no tracker) com o destino, as notas, as decisões já tomadas e a **névoa** (o que ainda não dá para especificar). Os **tickets de decisão** são de quatro tipos: `research` (pesquisa por subagente), `prototype`, `grilling` e `task`. Um ticket por sessão é resolvido, por vez, até o caminho ficar claro. O resultado são decisões, não entregas: o mapa se integra ao fluxo principal em `/to-spec`.

**Quando usar:** quando o trabalho é grande, nebuloso e não cabe em uma sessão, por exemplo um projeto do zero. Para uma funcionalidade bem delimitada, use `/grill-with-docs`, que é mais rápida.

**Como invocar:** `/wayfinder`, com uma ideia para desenhar o mapa ou com um mapa existente para continuar. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
