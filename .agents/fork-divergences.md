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

## Changed behaviour

Each of these is a fork feature that an upstream rewrite would delete without conflicting. The phrase in the last column is what to grep for when checking whether the merge took upstream's version back.

| Skill | What this fork does that upstream doesn't | Grep for upstream's version |
| --- | --- | --- |
| `review-axes` | **Working-tree mode**: accepts "the unstaged working tree" as the fixed point, diffs `git diff` after `git add -N .`, skips the ref check | `excludes staged and working-tree changes` with no fork caveat after it |
| `review-axes` | Spec search is **local-markdown first** — argument, then `.scratch/`/`docs/`/`specs/`, then remote tracker refs | `Issue references in the commit messages` as item 1 |
| `review-axes` | **Step 6**: syncs `- [ ]` / `- [x]` acceptance criteria on the local spec, advances `Status:` to `ready-for-human` when all are checked | a Process that ends at `### 5. Aggregate` |
| `review-axes` | **Model-by-host table** for the two sub-agents (Haiku on Claude Code; `claude-4.5-haiku-thinking` on Cursor, never `composer-2.5`) | `### 4. Spawn both sub-agents in parallel` followed straight by the Standards prompt |
| `implement` | Hands `/review-axes` **the unstaged working tree**, and leaves checkbox syncing to it | `does not tick the` |
| `wayfinder` | Grilling tickets are worked **one question at a time** | `Conversation. The default case.` |

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
- Install commands come from `.agents/install-block.md`, verbatim.
- The Portuguese guides under `docs/guides/pt-br/` are fork-only.
