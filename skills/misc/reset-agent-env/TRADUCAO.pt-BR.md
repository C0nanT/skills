```yaml
name: reset-agent-env
description: Redefine os ambientes globais de agentes, apagando skills, hooks, regras e configurações de MCP instalados no Claude Code, Cursor, Windsurf, Antigravity e no diretório padrão do Agent-Skills, para simular uma máquina limpa.
disable-model-invocation: true
```

# Redefinir o ambiente de agentes

Apague a configuração global de agentes desta máquina: skills, hooks, regras e servidores MCP, em todos os harnesses de agentes, para que você possa testar uma instalação do zero ou entregar um ambiente limpo.

Destrutivo. O script usa por padrão um **dry run**; nada é removido até que você confirme um modo.

## Processo

### 1. Inventário (dry run)

Rode o script incluído sem flags. Ele lista exatamente o que existe e o que seria removido, agrupado por agente, e não altera nada:

```bash
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh
```

Mostre a saída ao usuário.

### 2. Confirme o escopo e o modo

Pergunte ao usuário duas coisas:

- **Quais agentes?** Todos (padrão), ou um subconjunto via `--agent`, que pode ser repetido:
  `claude` · `agents` (o diretório padrão `~/.agents/skills`) · `cursor` · `windsurf` · `antigravity`.
- **Backup ou exclusão definitiva?**
  - `--apply` (recomendado): move tudo para `~/.cache/agent-env-reset/<timestamp>/`, então é reversível.
  - `--hard`: apaga de vez, sem backup.

### 3. Execute

Rode com as flags escolhidas mais `--yes` (o usuário já confirmou):

```bash
# everything, reversible:
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --apply --yes

# scoped + hard delete:
bash ~/.claude/skills/reset-agent-env/scripts/reset-agent-env.sh --hard --agent claude --agent cursor --yes
```

### 4. Relate

Diga ao usuário o que foi removido. Para `--apply`, informe o caminho do backup e a dica de restauração (mover os arquivos de volta para fora do diretório de backup).

Esta skill fica em `~/.claude/skills`, então uma redefinição completa do Claude Code **remove a própria skill**: reinstale com `npx skills@latest add C0nanT/skills` antes de usá-la de novo.

## O que ela toca

| Agente | Alvos |
| --- | --- |
| **Claude Code** | `~/.claude/skills`, `~/.claude/hooks-lib`, `~/.claude/hooks`, `~/.claude/commands`, `~/.claude/CLAUDE.md`; remove cirurgicamente `.hooks` de `settings.json` / `settings.local.json` e `.mcpServers` de `~/.claude.json` |
| **Padrão Agent-Skills** | `~/.agents/skills` |
| **Cursor** | `~/.cursor/rules`, `~/.cursor/mcp.json` |
| **Windsurf** | `~/.codeium/windsurf/memories/global_rules.md`, `~/.codeium/windsurf/mcp_config.json` |
| **Antigravity** | `~/.antigravity`, `~/.config/antigravity` (melhor esforço) |

## Notas

- A cobertura é completa para o **Claude Code** e para o diretório `~/.agents/skills`; é de melhor esforço para Cursor / Windsurf / Antigravity: só os caminhos que já existem são tocados.
- As edições em JSON são **cirúrgicas**: `settings.json` mantém seu modelo, tema e outras preferências; só a chave `.hooks` é removida.
- As etapas de JSON precisam de `jq`. Sem ele, são puladas com um aviso (as remoções de arquivos ainda rodam).
- Depois de redefinir, reinstale para verificar uma configuração limpa:

  ```bash
  npx skills@latest add C0nanT/skills
  # inside Claude Code:
  /plugin install conan-mods --marketplace C0nanT/claude-hooks
  ```
