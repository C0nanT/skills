# Resumo: delegate-tickets

**O que faz:** executa uma sequência de tickets, um de cada vez, cada um em um subagente novo que roda `/implement`. A sessão principal só orquestra: ordena os tickets pelas dependências (`Blocked by`), confere a dificuldade de todos antes de começar (Heavy ou sem `Difficulty:` interrompe a execução), exige uma árvore limpa no início, verifica cada resultado (commit feito, critérios marcados) e para no primeiro problema.

**Quando usar:** depois que o `/to-tickets` gerou os tickets, quando você quer que a construção rode sem supervisão em todos eles.

**Como invocar:** `/delegate-tickets`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
