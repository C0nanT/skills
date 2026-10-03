# 11: Fechamento: roteador relido e validação completa

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** depois de todas as mudanças, o `ask-skills` descreve corretamente como as skills se encaixam (TDD dentro do `/implement`, `/delegate-tickets` parando em Heavy e sem humano, pesquisa do `/wayfinder`). O repo passa em todas as validações, e o Findings ledger do módulo Engineering skills mostra as 10 linhas resolvidas, cada uma com seu commit.

**Blocked by:** 01, 02, 03, 04, 05, 06, 07, 08, 09, 10

Status: ready-for-human

- [x] `ask-skills` relido inteiro e coerente com as skills alteradas
- [x] `scripts/validate.sh` passa
- [x] `claude plugin validate . --strict` passa
- [x] Nenhum em-dash em texto novo
- [x] Findings ledger com as 10 linhas resolvidas e os commits correspondentes; coluna Open do índice zerada
