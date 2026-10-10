# Resumo: reset-agent-env

**O que faz:** apaga a configuração **global** de agentes desta máquina (skills, hooks, regras e servidores MCP) em Claude Code, Cursor, Windsurf, Antigravity e no diretório padrão `~/.agents/skills`. Começa sempre com um inventário (dry run) e só remove depois de você escolher o modo: `--apply` move tudo para um backup reversível em `~/.cache/agent-env-reset/`, e `--hard` apaga sem volta. Edita o JSON de configuração de forma cirúrgica, mantendo modelo, tema e demais preferências.

**Quando usar:** para testar uma instalação do zero ou entregar uma máquina limpa. Atenção: como esta skill fica em `~/.claude/skills`, a redefinição do Claude Code remove a própria skill.

**Como invocar:** `/reset-agent-env`. É uma skill só para o usuário (`disable-model-invocation: true`). Está em `misc/`, ou seja, é de uso raro.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `scripts/reset-agent-env.sh` (script, não traduzido por ser código) e este `RESUMO.md`.
