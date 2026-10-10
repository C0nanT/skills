# Resumo: implement-spec

**O que faz:** implementa em código uma especificação que já tem tickets, gerados por `/to-spec` e `/to-tickets`. Os tickets formam um grafo de dependências. Subagentes implementadores trabalham em paralelo, cada um em seu worktree, e um subagente de merge junta o trabalho em um **branch de integração**. Testes que mexem em estado compartilhado (banco, API, e2e) só rodam uma vez, em série, no branch de integração depois dos merges, para os paralelos não se corromperem. Depois roda `review-axes` e corrige os problemas encontrados. Depois marca o PR como pronto ou atualiza os tickets no tracker local.

**Quando usar:** quando uma especificação e seus tickets já estão prontos e você quer que sejam construídos.

**Como invocar:** `/implement-spec`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`. Usa as skills `tdd` e `review-axes`, além de `/archive-feature`.
