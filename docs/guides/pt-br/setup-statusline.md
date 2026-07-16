# `/setup-statusline` — Barra de status do Claude Code

## O que é

Uma skill de instalação única que copia scripts bundled e registra uma status line no `~/.claude/settings.json` — modelo, contexto (% + tokens), duração, rate limit e branch git.

## Para que serve

- Ver uso de contexto (% + tokens) e duração no prompt
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
| Context usage | `ctx:14% 28k` bold yellow |
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
3. Registra `statusLine` e hooks `SessionEnd`/`SessionStart` (matcher `clear`) em `~/.claude/settings.json`
4. Verifica com um JSON de teste

Scripts fonte em runtime: `~/.claude/skills/setup-statusline/scripts/` (após `npx skills@latest`).

## Comportamento do `/clear`

`/clear` zera a duração na barra. É um comando local do cliente — **não** dispara `UserPromptSubmit` — então o reset usa:

- Hooks `SessionEnd` / `SessionStart` (matcher `clear`) → gravam baseline em `~/.claude/statusline-baseline.json` (custo USD só como sinal de `/clear`, não aparece na barra)
- Fallback no script: `session_id` muda e custo quase igual (&lt; $0.05) → trata como `/clear` e grava baseline
- Script subtrai baseline de duração nas leituras seguintes
- Novo processo Claude (custo abaixo da baseline) limpa baseline automaticamente

`ctx:%` + tokens vêm da janela ao vivo e zeram naturalmente após `/clear`.

## Dicas

- Efeito na próxima sessão Claude Code (ou imediato para updates mid-session).
- Fora do escopo de um repo — configuração global em `~/.claude/`.
