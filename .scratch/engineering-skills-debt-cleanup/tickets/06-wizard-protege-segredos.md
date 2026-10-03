# 06: `wizard` protege segredos

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** antes de gravar o primeiro valor, o wizard gerado confere se o arquivo de env está no `.gitignore`. Se não estiver, pede confirmação ou oferece incluir o arquivo no `.gitignore`. Se já estiver, segue sem perguntar nada. A checagem estática do script gerado inclui esse item. O `validate.sh` testa a biblioteca num repo git temporário, reaproveitando o mecanismo de extração de snippet do ticket 01. É a linha 9 do mapa (spec, histórias 56 a 59).

**Blocked by:** 01 (mecanismo de extração de snippet no `validate.sh`)

Status: ready-for-agent

- [ ] Com arquivo de env fora do `.gitignore`, `write_env` não grava sem confirmação
- [ ] Há a opção de incluir o arquivo no `.gitignore`
- [ ] Com arquivo de env já ignorado, nenhuma pergunta extra
- [ ] A checagem estática do passo 4 do `SKILL.md` inclui "ENV_FILE is gitignored"
- [ ] `validate.sh` roda os dois cenários num repo git temporário e falha se algum quebrar
- [ ] Docs do `wizard` atualizados
- [ ] Linha 9 marcada como resolvida no Findings ledger
- [ ] `scripts/validate.sh` passa
