# 07: `delegate-tickets` só nível médio e para sem humano

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**What to build:** o `/delegate-tickets` lê a linha `Difficulty:` de cada ticket antes de começar. Ticket Heavy, ou sem a linha, para a sequência com uma mensagem dizendo que aquele ticket precisa de Opus e de um humano por perto. Tickets Standard e Light rodam num sub-agente Sonnet (ou equivalente no host) com `effort: medium`. O prompt do sub-agente diz que qualquer pergunta ao usuário vira bloqueio reportado, nunca trabalho inline. No `/implement`, o fallback do gate de esforço alto, quando não há humano, passa a ser parar e perguntar; numa sessão interativa ele continua perguntando como hoje. É a linha 5 do mapa (spec, histórias 29 a 35).

**Blocked by:** 02 (mexe no `implement`)

Status: ready-for-human

- [x] `delegate-tickets` lê `Difficulty:` antes de cada ticket
- [x] Ticket Heavy para a sequência com mensagem explicando o motivo
- [x] Ticket sem `Difficulty:` para a sequência como bloqueio
- [x] Sub-agente de Standard e Light em Sonnet (ou equivalente) com `effort: medium`
- [x] Prompt do sub-agente: qualquer pergunta ao usuário vira bloqueio, nunca inline
- [x] `implement`: sem humano, o gate de esforço alto para e pergunta; "do the work inline" não é mais o fallback
- [x] `implement` interativo continua pedindo o sim antes de spawn em esforço alto
- [x] Docs de `implement` (e do `delegate-tickets` se houver) e guias atualizados
- [x] Linha 5 marcada como resolvida no Findings ledger
- [x] `scripts/validate.sh` passa
