# `/reset-agent-env` — Resetar ambientes globais de agentes

## O que é

Uma skill user-invoked de manutenção que limpa a configuração **global** de agentes
nesta máquina — skills instaladas, hooks, rules e MCP servers — em todos os
harnesses de agente. Use para simular uma máquina limpa antes de testar uma
instalação do zero.

É destrutiva, então o script embutido roda em **dry-run** por padrão: lista o que
seria removido e não muda nada até você escolher um modo.

## Para que serve

- Simular um PC novo para verificar se `npx skills add` / `npx @c0nant/claude-hooks install` funcionam de ponta a ponta
- Limpar resíduo cross-tool deixado por desinstalações parciais
- Entregar um ambiente limpo

## Como invocar

```
/reset-agent-env
```

## Como funciona

1. **Inventário (dry-run)** — roda o script sem flags e mostra, agrupado por agente,
   exatamente quais caminhos existem e seriam removidos. Nada muda.
2. **Confirma escopo e modo** — você escolhe quais agentes e se faz backup ou apaga de vez.
3. **Executa** — roda o script com suas flags.
4. **Reporta** — lista o que foi removido e, no `--apply`, o caminho do backup.

## Modos e flags

| Flag | Efeito |
|------|--------|
| *(nenhuma)* | Dry-run — só inventário, nada removido |
| `--apply` | Move os alvos para `~/.cache/agent-env-reset/<timestamp>/` (reversível) |
| `--hard` | Apaga os alvos de vez (sem backup) |
| `--agent <nome>` | Limita a um agente (repetível): `claude` · `agents` · `cursor` · `windsurf` · `antigravity` |
| `--yes` | Pula a confirmação |

```bash
# inventário (seguro)
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh
# limpa tudo, reversível
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --apply --yes
# com escopo, apagando de vez
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --hard --agent claude --agent cursor --yes
```

## O que ele mexe

| Agente | Alvos |
|--------|-------|
| **Claude Code** | `~/.claude/skills`, `~/.claude/hooks-lib`, `~/.claude/hooks`, `~/.claude/commands`, `~/.claude/CLAUDE.md`; remove `.hooks` do `settings.json` / `settings.local.json` e `.mcpServers` do `~/.claude.json` |
| **Agent-Skills padrão** | `~/.agents/skills` |
| **Cursor** | `~/.cursor/rules`, `~/.cursor/mcp.json` |
| **Windsurf** | `~/.codeium/windsurf/memories/global_rules.md`, `~/.codeium/windsurf/mcp_config.json` |
| **Antigravity** | `~/.antigravity`, `~/.config/antigravity` (best-effort) |

## Notas

- Cobertura completa para **Claude Code** e o dir **`~/.agents/skills`**;
  best-effort para Cursor / Windsurf / Antigravity — só toca em caminhos que existem.
- Edições de JSON são cirúrgicas (`del(.hooks)`, `del(.mcpServers)`) — modelo, tema
  e demais preferências no `settings.json` são preservados. Esses passos precisam de `jq`.
- A skill vive em `~/.claude/skills`, então um reset completo do Claude Code **remove
  a própria skill** — reinstale com `npx skills@latest add C0nanT/skills` depois.
- Reinstale para verificar um setup limpo:
  ```bash
  npx skills@latest add C0nanT/skills
  npx @c0nant/claude-hooks install
  ```
