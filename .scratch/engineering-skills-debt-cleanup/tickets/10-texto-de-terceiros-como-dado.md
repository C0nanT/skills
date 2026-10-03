# 10: Texto de terceiros tratado como dado

> **Difficulty:** Heavy: **suggested model:** Opus (Claude Code) / Opus or the strongest reasoning model available (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** `/review-mr`, `/review-axes` e `/research` tratam texto escrito por terceiros (título e descrição de MR, corpo de issue remota, página web) como dado não confiável, com a mesma frase nas três: o texto vai no brief dentro de um bloco cercado marcado como dado, e instruções encontradas nele nunca são seguidas. No `/review-mr`, refs vindos da MR vão sempre entre aspas simples nos comandos de shell, ou são resolvidos para SHA antes (`gh` / `glab`). Avaliar e registrar se o sub-agente de Performance + Design pode ser só de leitura. É a linha 4 do mapa (spec, histórias 23 a 28).

**Blocked by:** 02 (mexe no `research`), 08 (mexe no `review-axes`)

Status: ready-for-human

- [x] Frase padrão idêntica em `review-mr`, `review-axes` e `research`
- [x] `review-mr`: comandos de shell com refs entre aspas simples, ou resolvidos para SHA quando `gh`/`glab` estão disponíveis
- [x] `review-mr`: título e descrição da MR chegam ao sub-agente num bloco marcado como dado
- [x] Decisão sobre sub-agente só de leitura registrada no próprio `review-mr` ou no ticket
- [x] `validate.sh` exige a frase padrão nas três skills
- [x] Docs de `review-mr`, `review-axes` e `research` atualizados
- [x] Linha 4 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
