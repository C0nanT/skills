# `/setup-pre-commit` — Configurar Pre-commit Hooks

## O que é

Uma skill que configura hooks de pre-commit no repositório usando Husky, lint-staged, e Prettier — com type checking e testes opcionais no hook.

## Para que serve

- Quando você quer que o código seja formatado automaticamente antes de cada commit
- Para garantir que type errors não sejam commitados
- Para garantir que testes sempre passem antes de um commit
- Como setup inicial de qualidade de código em um projeto novo

## Como invocar

```
/setup-pre-commit
```

## O que é configurado

- **Husky** — gerenciador de pre-commit hooks para Node.js
- **lint-staged** — roda Prettier só nos arquivos staged (rápido)
- **Prettier** — formatação de código (cria `.prettierrc` se não existe)
- **typecheck** — roda `npm run typecheck` no hook (se o script existir)
- **test** — roda `npm run test` no hook (se o script existir)

## Como funciona

**1. Detecta o package manager** — verifica qual lockfile existe:
- `package-lock.json` → npm
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn
- `bun.lockb` → bun

**2. Instala dependências:**
```bash
npm install -D husky lint-staged prettier
# (ou pnpm/yarn/bun equivalente)
```

**3. Inicializa o Husky:**
```bash
npx husky init
```
Cria o diretório `.husky/` e adiciona `prepare: "husky"` ao `package.json`.

**4. Cria `.husky/pre-commit`:**
```
npx lint-staged
npm run typecheck
npm run test
```
Adapta para o package manager detectado. Omite `typecheck` e `test` se os scripts não existem no `package.json`.

**5. Cria `.lintstagedrc`:**
```json
{
  "*": "prettier --ignore-unknown --write"
}
```

**6. Cria `.prettierrc`** (só se não existir):
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

**7. Verifica** — checa que todos os arquivos foram criados corretamente e roda `npx lint-staged` para confirmar que funciona.

**8. Commita** — faz commit de tudo com mensagem: `Add pre-commit hooks (husky + lint-staged + prettier)`. Este primeiro commit passa pelos próprios hooks — é um smoke test natural.

## Checklist de verificação

```
[ ] .husky/pre-commit existe e é executável
[ ] .lintstagedrc existe
[ ] "prepare" script no package.json é "husky"
[ ] Prettier config existe
[ ] npx lint-staged roda sem erros
```

## Exemplo de uso

```
Quero configurar pre-commit hooks neste projeto TypeScript com pnpm.

/setup-pre-commit
```

O agente vai detectar pnpm, instalar as dependências, configurar tudo, e fazer o primeiro commit com os hooks ativos.

## Notas técnicas

- Husky v9+ não precisa de shebangs nos arquivos de hook
- `prettier --ignore-unknown` pula arquivos que o Prettier não consegue parsear (imagens, etc.)
- O hook roda lint-staged primeiro (rápido, só arquivos staged), depois typecheck e tests completos
