# Guardrails de git

O git destrutivo é negado ao Claude Code neste repositório por meio de `permissions.deny` em `.claude/settings.json`, não por um hook. Hooks globais (se houver) são separados; este arquivo documenta apenas a lista de negações do projeto.

## Prefixos negados

- `Bash(git push *)`
- `Bash(git reset --hard *)`
- `Bash(git clean *)`
- `Bash(git -C * push)`
- `Bash(git -C * push *)`
- `Bash(git -C * reset --hard)`
- `Bash(git -C * reset --hard *)`
- `Bash(git -C * clean)`
- `Bash(git -C * clean *)`
- `Bash(git branch -D *)`
- `Bash(git branch --delete --force *)`
- `Bash(git checkout . *)`
- `Bash(git restore . *)`
- `Bash(git stash drop *)`
- `Bash(git stash clear *)`
- `Bash(git tag -d *)`
- `Bash(git tag -D *)`

O git do dia a dia não é negado: comandos somente leitura (`status`, `diff`, `log`, `show`, …) e os de que as skills dependem (`add`, `commit`, `merge`, `rebase`, `switch`, `worktree`, `stash`, `stash create`, `reset` soft ou mixed, `restore --source=<ref> --worktree -- <arquivos>`, `branch -d`).

## Quando um comando é negado

Uma negação é um sinal de parada. Relate ao usuário e espere; nunca contorne (nada de `bash -c`, `git -C`, `gh` ou chamada de API que faça a mesma coisa). Skills que dariam push, como o `/implement-spec` abrindo um PR em rascunho, relatam a branch para o usuário dar o push. Alternativas seguras para os comandos negados:

- Em vez de `git reset --hard <base>`: `git switch -C <branch> <base>`, ou `git worktree add -b <branch> <caminho> <base>`.
- Em vez de `git branch -D`: `git branch -d`, que recusa uma branch não mesclada.

As regras `git -C <dir>` vêm em pares porque um espaço seguido de `*` no fim só casa com o comando nu quando ele é o único curinga da regra. O `*` do meio pode abranger qualquer texto, então um comando somente leitura que apenas menciona um subcomando negado mais adiante (`git -C . log --grep push`) também é negado; rode-o sem `-C`.

Para alterar a lista, edite `.claude/settings.json` → `permissions.deny`.
