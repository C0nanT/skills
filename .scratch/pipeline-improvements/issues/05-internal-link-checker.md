Status: ready-for-agent

## What to build

Add an internal link check section to `scripts/validate.sh` that scans all `SKILL.md` files for markdown links with relative paths and verifies each target exists on disk.

- Extract relative links from `SKILL.md` files (links that don't start with `http://` or `https://`)
- Resolve each link relative to the directory containing the `SKILL.md` that references it
- Flag any link whose resolved target does not exist on disk

Error messages follow the format established in `01-fix-error-accumulation.md`. Format: `FAIL: <source-file>: broken link '<link>' → <resolved-path> not found`.

## Acceptance criteria

- [ ] Script fails (exit 1, actionable message) when a `SKILL.md` contains a relative link to a non-existent file
- [ ] Script passes when all relative links in `SKILL.md` files resolve to existing files
- [ ] Absolute URLs (`https://…`) are not checked
- [ ] Anchor fragments (`#section`) are ignored (only the file path portion is checked)
- [ ] All failures reported before exit

## Blocked by

- `01-fix-error-accumulation.md`
