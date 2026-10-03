# 08: `review-axes` recebe o caminho do ticket

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** o `/implement` passa ao `/review-axes` o caminho da spec ou do ticket que recebeu, e o prompt do sub-agente do `/delegate-tickets` diz explicitamente que o caminho do ticket é o argumento de spec. Assim o `review-axes` marca os checkboxes do ticket certo sem depender da heurística de busca, e o `delegate-tickets` deixa de reportar falha falsa. Sai do prompt do `delegate-tickets` o `git add -N .` que o `review-axes` já faz. É a linha 10 do mapa (spec, histórias 36 a 38).

**Blocked by:** 07 (mesmo prompt do `delegate-tickets` e mesma área do `implement`)

Status: ready-for-human

- [x] `implement` invoca o `review-axes` passando o caminho da spec ou do ticket recebido
- [x] Prompt do `delegate-tickets` passa o caminho do ticket como spec do `review-axes`
- [x] `git add -N .` removido do prompt do `delegate-tickets`
- [x] Heurística de busca de spec do `review-axes` sem mudança
- [x] Docs de `implement` e `review-axes` atualizados se descreverem o fluxo
- [x] Linha 10 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
