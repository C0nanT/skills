# `/git-guardrails-claude-code` — Bloqueio de Comandos Git Perigosos

## O que é

Uma skill que configura hooks do Claude Code para bloquear automaticamente comandos git perigosos antes que o agente os execute.

## Para que serve

- Quando você não quer que o agente faça `git push` acidentalmente
- Para prevenir que o agente resets ou deletes branches sem sua permissão
- Para adicionar uma camada de segurança em operações git destrutivas
- Especialmente útil em projetos com branches de produção

## Como invocar

```
/git-guardrails-claude-code
```

## O que é bloqueado

- `git push` (todas as variações, incluindo `--force`)
- `git reset --hard`
- `git clean -f` e `git clean -fd`
- `git branch -D`
- `git checkout .` e `git restore .`

Quando o agente tenta executar um desses comandos, recebe uma mensagem dizendo que não tem autoridade para executá-lo.

## Como funciona

### Processo

**1. Pergunta o escopo** — instalar só para este projeto (`.claude/settings.json`) ou globalmente para todos os projetos (`~/.claude/settings.json`)?

**2. Copia o script de hook**

Copia o script bundled para:
- **Projeto**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Torna o script executável com `chmod +x`.

**3. Adiciona o hook ao settings**

Adiciona uma entrada `PreToolUse` no arquivo de settings correspondente:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

Se o arquivo já existe, mergeia sem sobrescrever outras configurações.

**4. Pergunta sobre customização** — quer adicionar ou remover padrões da lista de bloqueio?

**5. Verifica** — roda um teste para confirmar que o script está funcionando:
```bash
echo '{"tool_input":{"command":"git push origin main"}}' | ./path/to/script
```
Deve sair com código 2 e imprimir uma mensagem BLOCKED.

## Exemplo de uso

```
Quero garantir que o Claude não faça push acidentalmente neste projeto.

/git-guardrails-claude-code
```

O agente vai perguntar: "Instalar só para este projeto ou globalmente?" — você escolhe, ele configura.

## Dicas

- **Escopo de projeto** é mais seguro como ponto de partida — só afeta o projeto atual
- **Escopo global** é conveniente se você sempre quer esses guardrails em todos os projetos
- Você pode editar o script copiado para adicionar/remover padrões específicos manualmente depois
- O hook é um `PreToolUse` — roda *antes* de qualquer comando Bash que o agente tente executar
