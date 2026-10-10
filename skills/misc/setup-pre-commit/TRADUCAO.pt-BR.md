```yaml
name: setup-pre-commit
description: Configure hooks de pre-commit do Husky com lint-staged (Prettier), checagem de tipos e testes no repositório atual. Use quando o usuário quiser adicionar hooks de pre-commit, configurar o Husky, configurar o lint-staged ou adicionar formatação, checagem de tipos ou testes no momento do commit.
```

# Configurar hooks de pre-commit

## O que isto configura

- Um hook de pre-commit do **Husky**
- **lint-staged** rodando o Prettier em todos os arquivos staged
- Configuração do **Prettier** (se estiver ausente)
- Scripts de **typecheck** e **test** dentro do hook de pre-commit

## Passos

### 1. Detecte o gerenciador de pacotes

Verifique a presença de `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn), `bun.lockb` (bun). Use o que estiver presente. Use npm por padrão se não estiver claro.

### 2. Instale as dependências

Instale como devDependencies:

```bash
husky lint-staged prettier
```

### 3. Inicialize o Husky

```bash
npx husky init
```

Isso cria o diretório `.husky/` e adiciona `prepare: "husky"` ao package.json.

### 4. Crie `.husky/pre-commit`

Escreva este arquivo (não precisa de shebang para Husky v9+):

```sh
npx lint-staged
npm run typecheck
npm run test
```

**Adapte**: substitua `npm` pelo gerenciador de pacotes detectado. Se o repositório não tiver um script `typecheck` ou `test` no package.json, omita essas linhas e diga isso ao usuário.

### 5. Crie `.lintstagedrc`

```json
{
  "*": "prettier --ignore-unknown --write"
}
```

### 6. Crie `.prettierrc` (se estiver ausente)

Crie somente se não existir nenhuma configuração do Prettier. Use estes padrões:

```json
{
  "useTabs": false,
  "tabWidth": 2,
  "printWidth": 80,
  "singleQuote": false,
  "trailingComma": "es5",
  "semi": true,
  "arrowParens": "always"
}
```

### 7. Verifique

- [ ] `.husky/pre-commit` existe e é executável
- [ ] `.lintstagedrc` existe
- [ ] O script `prepare` no package.json é `"husky"`
- [ ] A configuração do `prettier` existe
- [ ] Rode `npx lint-staged` para verificar se funciona

### 8. Faça commit

Adicione ao stage todos os arquivos alterados ou criados e faça commit com a mensagem: `Add pre-commit hooks (husky + lint-staged + prettier)`

Isso vai passar pelos novos hooks de pre-commit: um bom teste de fumaça de que tudo funciona.

## Notas

- Arquivos de hook do Husky v9+ não precisam de shebang
- `prettier --ignore-unknown` pula arquivos que o Prettier não consegue interpretar (imagens etc.)
- O pre-commit roda primeiro o lint-staged (rápido, só os arquivos staged) e depois o typecheck e os testes completos
