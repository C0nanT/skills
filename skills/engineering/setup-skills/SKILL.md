---
name: setup-skills
description: Configure this repo for the engineering skills — set up its issue tracker, triage label vocabulary, domain doc layout, and project Claude Code permissions that deny destructive git. Run once before first use of the other engineering skills.
disable-model-invocation: true
---

# Setup Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker** — where issues live (Local markdown by default; GitHub / GitLab / other when you choose them here)
- **Triage labels** — the strings used for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them
- **Git guardrails** — `permissions.deny` entries in this repo's `.claude/settings.json` that block destructive git (`commit`, `push`, `reset`, …). Do **not** install or register hooks — the user already has hooks globally if they want them.

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use
- `.claude/settings.json` — does `permissions.deny` already list the destructive-git `Bash(git …)` rules?
- Is the `triage` skill installed? (a `triage` skill folder alongside this one, or `triage` in your available skills.) This decides whether Section B runs at all.
- Monorepo signals — a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. Present only in a genuinely large multi-package repo; their absence means single-context, which is almost every repo.

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order — one section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Give a one-line explainer only when the choice genuinely branches; skip the section entirely when exploration already settled it (Section B when `triage` isn't installed, Section C when there's no monorepo, Section D when the project deny list is already present).

**Section A — Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-tickets` and `to-spec` read this file and publish there without asking each run — so pick the place you actually track work. If you skip setup (or haven't run it yet), those skills fall back to **Local markdown** on their own. A user can still override the destination for a single run by asking explicitly.

Default posture: prefer **Local markdown** unless the user clearly wants a remote tracker. If a `git remote` points at GitHub and the user wants remote issues, propose GitHub. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host) and they want remote issues, propose GitLab. Otherwise offer:

- **Local markdown** (recommended default) — issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or when you don't want to create remote issues)
- **GitHub** — issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** — issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Other** (Jira, Linear, etc.) — ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

Record the choice in `docs/agents/issue-tracker.md`. The GitHub and GitLab templates carry a "PRs as a request surface" flag, defaulted **off** — leave it off and don't raise it; a user who wants external PRs in the triage queue can flip the flag in the file later.

> Explainer: Open-source repos often receive feature requests as pull requests, not just issues — a PR is an issue with attached code. If you turn this on, external PRs are pulled into the same triage queue and run through the same labels and states as issues (collaborators' in-flight PRs are left alone). Leave it off if PRs aren't a request surface for you.

**Section B — Triage labels.** Only if `triage` is installed.

If it is installed, ask exactly one question:

> Do you want to keep the default triage labels? (recommended: **yes**)

> Explainer: When an incoming issue is triaged, it moves through a state machine — needs evaluation, waiting on reporter, ready for an AFK agent to pick up, ready for a human, or won't fix. To do that, the engineering skills apply labels (or the equivalent in your issue tracker) that match strings *you've actually configured*. If your repo already uses different label names (e.g. `bug:triage` instead of `needs-triage`), map them here so the right ones are applied instead of creating duplicates.

**Section C — Domain docs.** Default to **single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root. This fits almost every repo; write it without asking.

Offer **multi-context** — a root `CONTEXT-MAP.md` pointing to per-context `CONTEXT.md` files — only when exploration found monorepo signals. Then confirm which layout they want.

**Section D — Git guardrails.** Recommended: **yes**. Skip when `.claude/settings.json` already contains the deny rules from the seed list below (all of them, or a clear superset the user customized).

> Add project `permissions.deny` rules that block destructive git in Claude Code? (recommended: **yes**)

> Explainer: Merges deny rules into **this repo's** `.claude/settings.json` only — no hooks, no scripts. Claude Code refuses `git commit`, `git push`, `git reset`, `git clean`, `git rebase`, force branch deletes, discard-all checkouts/restores, stash drop/clear, and force-delete tags. Read-only git still works. Your existing global hooks stay untouched. Say **no** only if you want the agent free to mutate git history in this repo.

If the user says **no**, omit the deny merge, `docs/agents/git-guardrails.md`, and the `### Git guardrails` sub-block. Do not remove existing deny rules when they say no.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and `docs/agents/triage-labels.md` (the last only when `triage` is installed)
- When Section D is yes: `docs/agents/git-guardrails.md` and the `permissions.deny` entries that will be merged into `.claude/settings.json`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### Git guardrails

Destructive git (`commit`, `push`, `reset`, …) is denied via `permissions.deny` in `.claude/settings.json`. See `docs/agents/git-guardrails.md`.
```

Include the `### Triage labels` sub-block, and write `docs/agents/triage-labels.md`, only when `triage` is installed and Section B ran. When it isn't, both are omitted.

Include the `### Git guardrails` sub-block and write `docs/agents/git-guardrails.md` only when Section D was **yes**. When Section D was **no**, omit them.

Then write the docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./triage-labels.md) — label mapping (only if `triage` is installed)
- [domain.md](./domain.md) — domain doc consumer rules + layout
- [git-guardrails.md](./git-guardrails.md) — documents the project deny list (only if Section D is yes)

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

#### 4a. Project git deny rules (Section D = yes only)

Write **only** into the target project's `.claude/settings.json`. Do **not** create `.claude/hooks/`, do **not** register `PreToolUse`, do **not** copy scripts, do **not** touch `~/.claude/settings.json`.

Requires `jq` (`command -v jq`).

Seed deny list (merge these strings into `permissions.deny`; keep any existing entries the project already has):

```text
Bash(git push *)
Bash(git commit *)
Bash(git reset *)
Bash(git clean *)
Bash(git rebase *)
Bash(git branch -D *)
Bash(git branch --delete --force *)
Bash(git checkout . *)
Bash(git restore . *)
Bash(git stash drop *)
Bash(git stash clear *)
Bash(git tag -d *)
Bash(git tag -D *)
```

Idempotent merge:

```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
SETTINGS="$PROJECT_ROOT/.claude/settings.json"

mkdir -p "$(dirname "$SETTINGS")"
if [ ! -s "$SETTINGS" ] || ! jq -e . "$SETTINGS" >/dev/null 2>&1; then
  echo '{}' > "$SETTINGS"
fi

jq '
  .permissions //= {}
  | .permissions.deny //= []
  | .permissions.deny = (
      .permissions.deny + [
        "Bash(git push *)",
        "Bash(git commit *)",
        "Bash(git reset *)",
        "Bash(git clean *)",
        "Bash(git rebase *)",
        "Bash(git branch -D *)",
        "Bash(git branch --delete --force *)",
        "Bash(git checkout . *)",
        "Bash(git restore . *)",
        "Bash(git stash drop *)",
        "Bash(git stash clear *)",
        "Bash(git tag -d *)",
        "Bash(git tag -D *)"
      ] | unique
    )
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
```

Also write `docs/agents/git-guardrails.md` from the seed template.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files. If git guardrails were added, point at `.claude/settings.json` → `permissions.deny` (not hooks). Mention they can edit `docs/agents/*.md` and the deny list directly later — re-running this skill is only necessary if they want to switch issue trackers, refresh deny rules, or restart from scratch.
