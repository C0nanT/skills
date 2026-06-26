Status: ready-for-agent

## What to build

Create a `package.json` at the repo root (none exists yet) and add `.github/workflows/publish.yml` that publishes the package to npm automatically on every merge to `main`, but skips publication if the version in `package.json` hasn't changed since the previous commit.

The workflow steps:
1. Trigger: `push` to `main` only
2. Checkout → Node setup (LTS)
3. Version-change guard: `git diff HEAD~1 -- package.json | grep '"version"'` — exit 0 (skip) if no match
4. `npm publish --access public` using `NODE_AUTH_TOKEN` from `secrets.NPM_TOKEN`

The `package.json` should declare the package name that matches the existing `npx skills@latest` install convention, with `"files"` pointing at the assets distributed to end users.

Add a brief note in `scripts/` or a `CONTRIBUTING.md` that `NPM_TOKEN` must be added as a GitHub Actions secret by the repo owner before publishing will work.

## Acceptance criteria

- [ ] `.github/workflows/publish.yml` exists and is syntactically valid (passes `actionlint` or equivalent YAML lint)
- [ ] `package.json` exists at repo root with `name`, `version`, `files`, and `publishConfig.access: "public"`
- [ ] Workflow skips `npm publish` (exits 0) when `package.json` version is unchanged vs. `HEAD~1`
- [ ] Workflow uses `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` — no hardcoded credentials
- [ ] Workflow triggers only on push to `main`, not on PRs
- [ ] `NPM_TOKEN` secret requirement is documented

## Blocked by

None — can start immediately
