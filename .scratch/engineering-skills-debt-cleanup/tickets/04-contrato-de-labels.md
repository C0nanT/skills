# 04: Contrato de labels de triagem

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** o `/setup-skills` sempre oferece o mapeamento de labels (Seção B), com "manter os padrões" como resposta recomendada, e sempre gera `docs/agents/triage-labels.md`. `ready-for-human` passa a significar "precisa de um humano: revisar a tarefa, o código e se a feature funciona", o que bate com o uso do `/review-axes`. Os templates de GitHub e GitLab param de citar um passo de triagem que o fork não tem. O `/to-tickets` escreve `Status:` sem negrito. É a linha 6 do mapa (spec, histórias 39 a 45).

**Blocked by:** 03 (mexe nos mesmos templates do `setup-skills`)

Status: ready-for-human

- [x] Nenhuma menção a "if `triage` is installed" no `setup-skills`; a Seção B sempre roda
- [x] A lista de arquivos gerados sempre inclui `docs/agents/triage-labels.md`
- [x] A definição de `ready-for-human` no template de labels foi reescrita; o label não mudou de nome
- [x] Templates de GitHub e GitLab sem referência ao "triage step"
- [x] `to-tickets` emite `Status:` sem negrito, no template local e onde mais aparecer
- [x] Ledger de divergências registra a Seção B incondicional
- [x] Docs do `setup-skills` e do `to-tickets` atualizados
- [x] Linha 6 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
