# 01: Merge seguro do settings e deny com `-C`

> **Difficulty:** Heavy: **suggested model:** Opus (Claude Code) / Opus or the strongest reasoning model available (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** quem roda o `/setup-skills` nunca perde o `.claude/settings.json` do projeto. Sem `jq`, o setup para e avisa. Com JSON inválido, para e mostra o erro. Com arquivo válido, só acrescenta as deny rules e faz backup antes de substituir. Sem arquivo, ou com arquivo vazio, cria como hoje. A lista de deny passa a cobrir também `git -C <dir>` para push, commit, reset, clean e rebase, nas duas cópias da lista (texto e snippet). O `validate.sh` ganha uma seção que extrai o snippet por um marcador estável e o roda num diretório temporário. É a linha 1 do mapa de 2026-10-03 (spec, histórias 1 a 7).

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] Sem `jq` no PATH, o snippet sai com erro e o `settings.json` existente fica byte a byte igual
- [x] Com `settings.json` inválido, o snippet sai com erro, mostra o problema e não altera o arquivo
- [x] Com `settings.json` válido contendo allow rules, hooks e env, tudo continua lá depois do merge e as deny rules aparecem
- [x] Um backup do arquivo anterior é criado antes da substituição
- [x] Sem arquivo ou com arquivo vazio, o settings é criado com as deny rules
- [x] A segunda execução não duplica regras
- [x] As variantes `git -C` estão nas duas cópias da lista, e o formato do glob foi conferido contra a documentação de permissões do Claude Code
- [x] O `validate.sh` tem a seção que roda os cenários acima e falha se algum quebrar
- [x] A página de docs do `setup-skills` e os guias en/pt-br do setup-skills refletem o novo comportamento
- [x] Linha 1 marcada como resolvida no Findings ledger de `docs/tech-debt/README.md`
- [x] `scripts/validate.sh` passa
