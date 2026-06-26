Status: ready-for-agent

## What to build

Create `scripts/test-validate.sh` — a fixture-based test suite for `scripts/validate.sh` that verifies observable behavior (exit code + stderr) without testing internal bash logic.

Each test:
1. Creates a minimal skill tree under `mktemp -d`
2. Runs `validate.sh` against that fixture (point it at the temp dir, not the real repo)
3. Asserts the expected exit code and that stderr contains the expected error substring
4. Cleans up the temp dir

Cover at minimum:
- **Happy path**: a fully valid skill tree exits 0
- **Error accumulation** (01): two independent failures both appear in output before exit
- **plugin.json → disk** (02): entry points to missing directory → exit 1 with path in message
- **disk → plugin.json** (02): public SKILL.md absent from plugin.json → exit 1
- **private in plugin.json** (02): private SKILL.md present in plugin.json → exit 1
- **bucket README missing skill** (03): SKILL.md not linked in bucket README → exit 1
- **bucket README stale link** (03): bucket README links non-existent SKILL.md → exit 1
- **markdownlint violation** (04): a SKILL.md with a known lint error → exit 1
- **broken internal link** (05): a SKILL.md with a relative link to a missing file → exit 1

The test script should print `ok` / `FAIL` per test and exit 1 if any test fails.

## Acceptance criteria

- [ ] `scripts/test-validate.sh` exists and is executable
- [ ] All tests listed above are present
- [ ] Suite exits 0 when all tests pass, 1 when any fail
- [ ] Each failing test prints which assertion failed and what was observed
- [ ] No reliance on the real repo's skill tree — all fixtures are self-contained temp dirs
- [ ] Suite can be run locally with `bash scripts/test-validate.sh`

## Blocked by

- `01-fix-error-accumulation.md`
- `02-plugin-json-consistency.md`
- `03-bucket-readme-content.md`
- `04-markdownlint-integration.md`
- `05-internal-link-checker.md`
