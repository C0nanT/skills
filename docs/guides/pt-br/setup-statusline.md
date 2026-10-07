# `/setup-statusline`: Migrar a barra de status para o `conan-mods`

## O que é

A barra de status (modelo, effort, contexto, duração, rate limit e branch git) agora é a função `statusline` do plugin `conan-mods`. A skill não instala mais nada: ela limpa o modelo antigo (script bash + hook shell) e manda instalar o plugin.

## Como invocar

```
/setup-statusline
```

## O que a skill faz

1. Remove do `~/.claude/settings.json` o `statusLine` que aponta para `statusline-command.sh`.
2. Remove as entradas com o marcador `claude-hook:statusline-reset` em `SessionStart`, `SessionEnd` e `UserPromptSubmit`.
3. Apaga `~/.claude/statusline-command.sh`, `~/.claude/statusline-reset-hook.sh` e `~/.claude/statusline-baseline.json`.
4. Manda instalar o plugin.

O resto do `settings.json` fica intacto.

## Instalar o plugin

```text
/plugin install conan-mods --marketplace C0nanT/claude-hooks
```

Já instalado: `claude plugin update conan-mods` e depois `/reload-plugins`.

## Ligar/desligar

```text
/conan-mods statusline on
/conan-mods statusline off
```

## Pré-requisitos

- `jq` (só para a limpeza)

## Dicas

- Relógio de reset (`↺ 10:00`) usa o fuso do PC. Override: `STATUSLINE_TZ=America/Sao_Paulo` em `~/.claude/settings.json` `env`.
- A duração zera sozinha no `/clear`, sem baseline em arquivo.
