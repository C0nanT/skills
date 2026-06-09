# `/setup-pre-commit` — Configure Pre-commit Hooks

## What it is

A skill that configures pre-commit hooks in the repository using Husky, lint-staged, and Prettier — with optional type checking and tests in the hook.

## What it's for

- When you want code to be automatically formatted before each commit
- To ensure type errors don't get committed
- To ensure tests always pass before a commit
- As initial code quality setup in a new project

## How to invoke

```
/setup-pre-commit
```

## What gets configured

- **Husky** — pre-commit hook manager for Node.js
- **lint-staged** — runs Prettier only on staged files (fast)
- **Prettier** — code formatting (creates `.prettierrc` if it doesn't exist)
- **typecheck** — runs `npm run typecheck` in the hook (if the script exists)
- **test** — runs `npm run test` in the hook (if the script exists)

## How it works

**1. Detects the package manager** — checks which lockfile exists:
- `package-lock.json` → npm
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn
- `bun.lockb` → bun

**2. Installs dependencies:**
```bash
npm install -D husky lint-staged prettier
# (or pnpm/yarn/bun equivalent)
```

**3. Initialises Husky:**
```bash
npx husky init
```
Creates the `.husky/` directory and adds `prepare: "husky"` to `package.json`.

**4. Creates `.husky/pre-commit`:**
```
npx lint-staged
npm run typecheck
npm run test
```
Adapts to the detected package manager. Omits `typecheck` and `test` if the scripts don't exist in `package.json`.

**5. Creates `.lintstagedrc`:**
```json
{
  "*": "prettier --ignore-unknown --write"
}
```

**6. Creates `.prettierrc`** (only if it doesn't exist):
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

**7. Verifies** — checks that all files were created correctly and runs `npx lint-staged` to confirm it works.

**8. Commits** — commits everything with the message: `Add pre-commit hooks (husky + lint-staged + prettier)`. This first commit goes through the hooks themselves — it's a natural smoke test.

## Verification checklist

```
[ ] .husky/pre-commit exists and is executable
[ ] .lintstagedrc exists
[ ] "prepare" script in package.json is "husky"
[ ] Prettier config exists
[ ] npx lint-staged runs without errors
```

## Usage example

```
I want to configure pre-commit hooks in this TypeScript project with pnpm.

/setup-pre-commit
```

The agent will detect pnpm, install the dependencies, configure everything, and make the first commit with the hooks active.

## Technical notes

- Husky v9+ doesn't need shebangs in hook files
- `prettier --ignore-unknown` skips files Prettier can't parse (images, etc.)
- The hook runs lint-staged first (fast, staged files only), then full typecheck and tests
