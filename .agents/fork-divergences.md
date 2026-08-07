# Fork divergences

Every way this repo deliberately differs from its upstream, [mattpocock/skills](https://github.com/mattpocock/skills) (the `upstream` remote). `/sync-upstream` reads this file to resolve merge conflicts and to sweep for divergences a clean merge overwrote silently. Anything not listed here is fair game for upstream to overwrite — so when you decide on a new divergence, record it the same day.

## Renamed skills

Upstream's name appears in its `SKILL.md` frontmatter, its directory, its docs page, its published slug (`https://aihero.dev/skills-<name>`), and in prose across every other skill's docs. A rename has to hold in all of them.

| Upstream | Here | Why |
| --- | --- | --- |
| `code-review` | `review-axes` | Claude Code ships its own `/code-review`; whichever wins, one of the two becomes unreachable. Renaming the fork is the only workaround `npx skills update` doesn't undo. |
| `ask-matt` | `ask-skills` | The router is over *this* set, and the docs name no author. |
| `setup-matt-pocock-skills` | `setup-skills` | Same. |

Upstream's directories for the first two still exist in the tree, unpromoted. Only the renamed copies are shipped — see `.claude-plugin/plugin.json`.

**Docs-page links follow the rename.** Upstream's docs pages are published at `https://aihero.dev/skills-<name>`; this fork's own `docs/` pages are not published anywhere. A merge that brings in upstream prose reintroduces the old `aihero.dev/skills-<upstream-name>` link text and the old skill name in the same breath — fix both, and link the renamed skill relatively (`./review-axes.md`, `./ask-skills.md`, `./setup-skills.md`) rather than to an `aihero.dev` slug that 404s. See `.agents/writing-docs.md` for the full rule. Sweep for it: `grep -rn "ask-matt\|setup-matt-pocock-skills\|code-review" docs/`.

## Changed behaviour

Each of these is a fork feature that an upstream rewrite would delete without conflicting. The phrase in the last column is what to grep for when checking whether the merge took upstream's version back.

| Skill | What this fork does that upstream doesn't | Grep for upstream's version |
| --- | --- | --- |
| `review-axes` | **Working-tree mode**: accepts "the unstaged working tree" as the fixed point, diffs `git diff` after `git add -N .`, skips the ref check | `excludes staged and working-tree changes` with no fork caveat after it |
| `review-axes` | Spec search is **local-markdown first** — argument, then `.scratch/`/`docs/`/`specs/`, then remote tracker refs | `Issue references in the commit messages` as item 1 |
| `review-axes` | **Step 6**: syncs `- [ ]` / `- [x]` acceptance criteria on the local spec, advances `Status:` to `ready-for-human` when all are checked | a Process that ends at `### 5. Aggregate` |
| `review-axes` | **Model-by-host table** for the two sub-agents (Haiku on Claude Code; `claude-4.5-haiku-thinking` on Cursor, never `composer-2.5`) | `### 4. Spawn both sub-agents in parallel` followed straight by the Standards prompt |
| `implement` | Hands `/review-axes` **the unstaged working tree**, and leaves checkbox syncing to it | `does not tick the` |
| `implement` | **Never commits** — only generates a Conventional Commits message (`type(scope): …` + why-body, ≤300 chars) for the user | `Commit your work to the current branch.` |
| `wayfinder` | Grilling tickets are worked **one question at a time** | `Conversation. The default case.` |
| `wayfinder` | Grilling ticket type invokes only `/grilling` — this fork carries no `domain-modeling` skill to pair it with | `/grilling and /domain-modeling` |
| `tdd` | Doesn't lean on an external skill for interface/seam vocabulary — this fork carries no `codebase-design` skill | `use the /codebase-design skill for the vocabulary` |

## Domain language

`CONTEXT.md` and `CLAUDE.md` are the source of truth; upstream's prose drifts from them.

- **Ticket**, not "issue", except when naming a real object on an external tracker.
- **Issue tracker**, not "backlog".
- Tickets default to local markdown under `.scratch/<feature-slug>/tickets/`, so a doc that treats a remote tracker as a prerequisite needs the local-first framing added back.

## Fork-only skills

Upstream has never seen these, so they never conflict — but they do go stale when an upstream skill they reference is renamed or rewritten: `ask-skills`, `caveman`, `delegate-tickets`, `frontend-handoff`, `review-mr`, `setup-skills`, `setup-solid`, `sync-upstream`, `reset-agent-env`, `setup-statusline`.

## Repo-level

- **Dropped upstream paths** live in `scripts/sync-upstream.sh` (`EXCLUDED_PATHS`) — that list is the ledger for deletions; add to it there, not here.
- `.claude-plugin/plugin.json` is this fork's own manifest (`conan-skills`, own author, own promoted set) and never takes upstream's. `.claude-plugin/marketplace.json` makes the repo its own single-plugin marketplace, which upstream does differently.
- **`skills/misc/` is partially promoted, unlike upstream.** `setup-pre-commit`, `setup-statusline`, and `reset-agent-env` all appear in `.claude-plugin/plugin.json`'s `skills` array and in the top-level `README.md`'s Misc section, even though `CLAUDE.md`'s Invariants section currently only names `engineering/` and `productivity/` as promoted buckets. This predates this sync (not introduced by a merge) — `CLAUDE.md`'s wording just hasn't caught up. Flagged here rather than silently "fixed" either direction; a human should decide whether to update the invariant text or un-promote those three.
- Install commands come from `.agents/install-block.md`, verbatim — **except this is currently untrue for `README.md`'s own `## Instalar` section**, which uses a from-scratch, Portuguese, single-command flow (`npx skills@latest add C0nanT/skills` + a separate `claude-hooks` install) instead of the plugin/skills.sh split `install-block.md` documents. `install-block.md` itself still names upstream's plugin (`mattpocock-skills`) and repo (`mattpocock/skills`) verbatim, so it does not describe this fork's actual install story either. Both predate this sync; flagged for a human decision (rewrite `install-block.md` to match the fork's real flow, or drop the "copied verbatim" claim from `CLAUDE.md`) rather than resolved unilaterally.
- The Portuguese guides under `docs/guides/pt-br/` are fork-only.
