# Resumo: setup-pre-commit

**O que faz:** configura, no repositório atual, hooks de pre-commit com **Husky**: o **lint-staged** formata os arquivos staged com Prettier, e o hook também roda a checagem de tipos e os testes do projeto. Detecta o gerenciador de pacotes pelo lockfile, instala as dependências, cria `.husky/pre-commit`, `.lintstagedrc` e, se faltar, `.prettierrc` com padrões definidos, verifica o resultado e faz um commit de teste de fumaça.

**Quando usar:** quando você quer que formatação, tipos e testes rodem automaticamente antes de cada commit.

**Como invocar:** o agente a chama sozinho quando você pedir hooks de pre-commit, Husky ou lint-staged (sem `disable-model-invocation`). Também pode pedir com `/setup-pre-commit`. Está em `misc/`, ou seja, é de uso raro.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
