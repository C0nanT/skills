# 09: Histórico do `tech-debt-map` no índice

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** o histórico de achados de cada módulo sobrevive a uma limpeza do `.scratch/` e a um clone novo. O formato do índice no passo 7 passa a incluir o "Findings ledger" por módulo (achado, primeira vez visto, status, commit que resolveu), como o `docs/tech-debt/README.md` deste repo já tem. O passo 5 lê o ledger quando o relatório anterior não existe e marca resolvidos a partir dele. O passo 7 atualiza o ledger ao final. Os relatórios continuam em `.scratch/`. É a linha 8 do mapa (spec, histórias 52 a 55).

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] Passo 7 descreve o Findings ledger como parte do índice
- [x] Passo 5 usa o ledger quando o relatório anterior não existe
- [x] Passo 7 atualiza status e commit dos achados ao final de cada revisão
- [x] Relatórios continuam em `.scratch/tech-debt-map/`
- [x] Docs do `tech-debt-map` atualizados
- [x] Linha 8 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
