# 05: Roteador `ask-skills` correto

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** quem segue o `ask-skills` recebe só fatos verdadeiros: tickets locais em `.scratch/<feature-slug>/tickets/`, `/implement` entregando a mensagem de commit sem commitar, e nenhuma entrada para `/diagnosing-bugs`. A descrição deixa de dizer "user-invoked skills". O grep do ledger para o caminho `issues/` passa a casar com qualquer placeholder, e a nota sobre `diagnosing-bugs` sai do ledger. É a linha 7 do mapa (spec, histórias 46 a 51).

**Blocked by:** 02 (modo e descrição do `implement`), 03 (nome da spec)

Status: ready-for-human

- [x] `ask-skills` cita `tickets/`, nunca `issues/`
- [x] `ask-skills` diz que o `/implement` nunca commita
- [x] Entrada de "Something's broken" / `/diagnosing-bugs` removida
- [x] Descrição do `ask-skills` diz "skills", não "user-invoked skills"
- [x] Grep do ledger para `issues/` aceita qualquer placeholder
- [x] Nota sobre `diagnosing-bugs` removida do ledger
- [x] `validate.sh` falha se `.scratch/<...>/issues/` reaparecer nas engineering skills ou se `/diagnosing-bugs` reaparecer no `ask-skills`
- [x] Docs e guias do `ask-skills` atualizados
- [x] Linha 7 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
