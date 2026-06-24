# `/setup-statusline` — Barra de status do Claude Code

## O que é

Uma skill de instalação única que copia scripts bundled e registra uma status line no `~/.claude/settings.json` — modelo, contexto, custo, duração, rate limit e branch git.

## Para que serve

- Ver uso de contexto (%), custo da sessão e duração no prompt
- Monitorar rate limit de 5 horas e horário de reset
- Ver modelo, effort level e branch git atual
- Restaurar configuração após reinstalar skills

## Como invocar

```
/setup-statusline
```

## Campos (esquerda → direita)

| Campo | Exemplo |
|-------|---------|
| Model name | bold cyan |
| Effort level | `(medium)` dim cyan, se presente |
| Context usage | `ctx:14%` bold yellow |
| Session cost | `$0.0123` green |
| Session duration | `23m` ou `1h05m` green |
| Rate limit | `limit:42% ↺ 14:30` verde/amarelo/vermelho |
| Git branch | bold magenta (omitido fora de repo git) |

Rate limit: verde &lt; 50%, amarelo 50–79%, vermelho ≥ 80%.

## Pré-requisitos

- `jq` instalado
- `bash` (Linux — `date -d @EPOCH` para reset time)

## O que a skill faz

1. Copia `statusline-command.sh` para `~/.claude/statusline-command.sh`
2. Copia `statusline-reset-hook.sh` para `~/.claude/statusline-reset-hook.sh`
3. Registra `statusLine` e hook `UserPromptSubmit` em `~/.claude/settings.json`
4. Verifica com um JSON de teste

Scripts fonte em runtime: `~/.claude/skills/setup-statusline/scripts/` (após `npx skills@latest`).

## Comportamento do `/clear`

`/clear` zera contadores de custo e duração na barra:

- Hook `UserPromptSubmit` grava baseline em `~/.claude/statusline-baseline.json`
- Script subtrai baseline nas leituras seguintes
- Novo processo Claude (custo abaixo da baseline) limpa baseline automaticamente

## Dicas

- Efeito na próxima sessão Claude Code (ou imediato para updates mid-session).
- Fora do escopo de um repo — configuração global em `~/.claude/`.
