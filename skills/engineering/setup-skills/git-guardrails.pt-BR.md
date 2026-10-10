# Guardrails de git

O git destrutivo é negado ao Claude Code neste repositório por meio de `permissions.deny` em `.claude/settings.json`, não por um hook. Hooks globais (se houver) são separados; este arquivo documenta apenas a lista de negações do projeto.

## Prefixos negados

- `Bash(git push *)`
- `Bash(git reset *)`
- `Bash(git clean *)`
- `Bash(git rebase *)`
- `Bash(git -C * push)`
- `Bash(git -C * push *)`
- `Bash(git -C * reset)`
- `Bash(git -C * reset *)`
- `Bash(git -C * clean)`
- `Bash(git -C * clean *)`
- `Bash(git -C * rebase)`
- `Bash(git -C * rebase *)`
- `Bash(git branch -D *)`
- `Bash(git branch --delete --force *)`
- `Bash(git checkout . *)`
- `Bash(git restore . *)`
- `Bash(git stash drop *)`
- `Bash(git stash clear *)`
- `Bash(git tag -d *)`
- `Bash(git tag -D *)`

O git somente leitura (`status`, `diff`, `log`, `show`, …) não é negado.

As regras `git -C <dir>` vêm em pares porque um espaço seguido de `*` no fim só casa com o comando nu quando ele é o único curinga da regra. O `*` do meio pode abranger qualquer texto, então um comando somente leitura que apenas menciona um subcomando negado mais adiante (`git -C . log --grep push`) também é negado; rode-o sem `-C`.

Para alterar a lista, edite `.claude/settings.json` → `permissions.deny`.
