# Resumo: tech-debt-map

**O que faz:** audita **um módulo** de uma base de código e produz um **mapa de dívida**: até 10 achados ordenados por retorno e raio de impacto, cada um com evidência (intervalo de linhas lido de fato), custo e estratégia de correção incremental, mais um plano em três fases. Usa quatro subagentes em paralelo, um por grupo de eixos (estrutura, código, regras de negócio e runtime, com base em `AXES.md`). Não altera código. Mantém um índice versionado em `docs/tech-debt/README.md`, com a data da última revisão de cada módulo, e um ledger de achados abertos e resolvidos.

**Quando usar:** para saber o que há de pior em um módulo antes de mexer nele, ou para revisar, ao longo do tempo, o que está sem dono e sem olhar.

**Como invocar:** `/tech-debt-map`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `AXES.md` / `AXES.pt-BR.md` (eixos e rubricas, em inglês e em português) e este `RESUMO.md`.
