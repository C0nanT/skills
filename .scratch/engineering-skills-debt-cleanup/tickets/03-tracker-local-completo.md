# 03: Tracker local completo e `SPEC.md` canônico

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** quem escolhe o tracker local no `/setup-skills` recebe um tracker doc com a seção "Wayfinding operations" (map, claim, bloqueio, fronteira), igual aos templates de GitHub e GitLab, usando `tickets/`. Toda skill e o tracker doc deste repo usam `SPEC.md`, então o `/frontend-handoff` acha a spec que o `/to-spec` escreveu. É a linha 2 do mapa (spec, histórias 8 a 12).

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] O template do tracker local tem a seção "Wayfinding operations", portada do tracker doc deste repo
- [x] `frontend-handoff` lê `SPEC.md`
- [x] O tracker doc deste repo usa `SPEC.md`
- [x] O template do tracker local consta na linha de `tickets/` do ledger de divergências
- [x] `validate.sh` falha se `spec.md` minúsculo aparecer como nome de spec nas engineering skills ou no tracker doc
- [x] Docs do `setup-skills` e do `wayfinder` refletem o template completo
- [x] Linha 2 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
