# Pipeline Improvements

Status: ready-for-agent

## Problem Statement

The CI pipeline currently runs a single structural validation script (`scripts/validate.sh`) that catches only a subset of consistency errors. Skills can exist on disk but be absent from `plugin.json`, bucket `README.md` files can omit skills without any error, `SKILL.md` files can contain broken internal links or malformed markdown, and there is no automated release process — publishing to npm requires manual intervention after every merge.

## Solution

Extend `scripts/validate.sh` with two new checks (plugin.json consistency, bucket README content), add markdownlint + internal link checking as a new validate section, and introduce a new `.github/workflows/publish.yml` that publishes the package to npm automatically on merge to `main`.

## User Stories

1. As a contributor, I want CI to catch when I add a skill to the filesystem but forget to add it to `plugin.json`, so that end users always get the skill via `npx skills@latest`.
2. As a contributor, I want CI to catch when `plugin.json` references a skill directory that doesn't exist, so that broken installs are caught before merge.
3. As a contributor, I want CI to catch when a public skill is missing from its bucket `README.md`, so that the bucket index stays accurate.
4. As a contributor, I want CI to catch when a bucket `README.md` lists a skill that doesn't exist on disk, so that stale entries are flagged immediately.
5. As a contributor, I want CI to lint my `SKILL.md` for common markdown issues (trailing whitespace, missing blank lines, heading hierarchy), so that formatting stays consistent across all skills.
6. As a contributor, I want CI to check that internal links in `SKILL.md` files resolve to real files, so that cross-skill references never silently break.
7. As a maintainer, I want a new npm release to be published automatically when a PR merges to `main`, so that I never have to remember to run `npm publish` manually.
8. As a maintainer, I want the publish workflow to use a scoped npm token stored as a GitHub secret, so that credentials are never exposed in the repo.
9. As a maintainer, I want the publish workflow to skip publication if the version in `package.json` hasn't changed, so that non-version bumps don't produce duplicate releases.
10. As a skill author, I want the validate script to report all failures at once (not stop on first error), so that I can fix all issues in one pass.
11. As a skill author, I want clear, actionable error messages that include the file path and the expected vs. actual state, so that I can locate and fix issues without reading the script source.
12. As a contributor, I want the pipeline to run on every push and PR (not just main), so that broken states are caught before they reach the default branch.

## Implementation Decisions

- **plugin.json validation added to `validate.sh`** — two sub-checks:
  1. Every path listed in `plugin.json#skills` must resolve to a directory containing a `SKILL.md`.
  2. Every `SKILL.md` under a public bucket (`engineering/`, `productivity/`, `misc/`) must appear in `plugin.json#skills`.
  Private buckets (`personal/`, `in-progress/`, `deprecated/`) must *not* appear in `plugin.json`.
- **Bucket README content check added to `validate.sh`** — for each public and private bucket, every skill directory with a `SKILL.md` must have its `SKILL.md` path linked in the bucket's `README.md`, and every linked path must exist.
- **Markdownlint added to `validate.sh`** — use `markdownlint-cli` (installed via `npm exec` or as a CI step pre-requisite) against all `SKILL.md`, `README.md`, and `REFERENCE.md` files. Config lives at `.markdownlint.json` in the repo root.
- **Internal link check added to `validate.sh`** — scan all `SKILL.md` files for markdown links with relative paths and verify each target exists on disk.
- **publish.yml** — new GitHub Actions workflow:
  - Trigger: `push` to `main` branch only.
  - Steps: checkout → Node setup → `npm ci` (if needed) → version-change guard (`git diff HEAD~1 -- package.json | grep '"version"'`) → `npm publish --access public` using `NODE_AUTH_TOKEN` from `secrets.NPM_TOKEN`.
  - Skips publish (exit 0) if version unchanged.
- **No new dependencies in the repo itself** — markdownlint-cli invoked via `npx` in CI so contributors don't need a local install.

## Testing Decisions

- **What makes a good test here:** validate the observable output of the script (exit code, stderr lines) given a controlled fixture directory — not the internal bash logic. Tests should create minimal skill trees (a few directories with known good/bad states) and assert that `validate.sh` exits 1 with the expected error message, or exits 0 with no errors.
- **Modules under test:**
  - `scripts/validate.sh` (all new sections + existing ones for regression)
  - `.github/workflows/publish.yml` — no unit test; validate via a dry-run flag or by asserting the workflow YAML is syntactically valid (`actionlint`).
- **Prior art:** no existing test suite — this project's tests are the validate script itself. New tests for the script can live in `scripts/test-validate.sh`, using `bash` subshells and fixture directories created with `mktemp -d`.

## Out of Scope

- Migrating from bash to a Node.js/Python test framework.
- Automated changelog generation or semantic-version bumping.
- PR templates or CODEOWNERS configuration.
- Checking `SKILL.md` content quality (descriptions, trigger phrasing) — that's a human review concern.
- Any changes to the runtime install layout (`~/.agents/skills/`) or `scripts/link-skills.sh`.

## Further Notes

- The `markdownlint` config should at minimum disable `MD013` (line length) since skill docs often contain long code blocks and prose that would be impractical to wrap.
- The version-change guard in `publish.yml` assumes a flat `package.json` at the repo root; if the repo adds workspaces later, the guard logic will need to be updated.
- `NPM_TOKEN` must be added as a GitHub Actions secret by the repo owner before `publish.yml` will work. Document this in `scripts/` or a brief `CONTRIBUTING.md` note.
