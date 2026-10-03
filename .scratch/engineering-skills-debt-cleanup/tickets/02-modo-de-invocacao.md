# 02: Modo de invocação único e checado

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** cada engineering skill tem um único modo de invocação, igual no `SKILL.md`, no `openai.yaml` e nos READMEs. `tdd` e `research` voltam a ser model-invoked, então o `/implement` alcança o `/tdd` e o `/wayfinder` alcança o `/research`. `implement` fica model-invoked nos dois harnesses. `delegate-tickets` e `setup-skills` ganham o arquivo de política do Codex e continuam user-invoked. A chamada do `implement` ao `tdd` usa a forma "Call the Skill tool with". O `validate.sh` passa a pegar qualquer divergência futura. É a linha 3 do mapa (spec, histórias 13 a 22).

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] `tdd` e `research` sem `disable-model-invocation`
- [x] `implement` sem bloco de política no `openai.yaml`
- [x] `delegate-tickets` e `setup-skills` com `agents/openai.yaml` e `allow_implicit_invocation: false`
- [x] `implement` chama o `tdd` pela forma "Call the Skill tool with"
- [x] README do bucket e README raiz com `implement`, `tdd` e `research` em Model-invoked, e a descrição do `implement` dizendo que entrega mensagem de commit e nunca commita
- [x] Ledger de divergências registra cada modo que difere do upstream, conferido contra o upstream
- [x] `validate.sh` falha quando `SKILL.md` e `openai.yaml` discordam sobre o modo
- [x] `validate.sh` falha quando uma skill não tem `agents/openai.yaml`
- [x] `validate.sh` falha quando uma skill chama pela Skill tool outra skill que não existe ou é user-invoked
- [x] Páginas de docs e guias de `implement`, `tdd` e `research` sem contradição com o novo modo
- [x] Linha 3 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
