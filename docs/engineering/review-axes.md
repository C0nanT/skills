## What it does

`review-axes` reviews the diff between `HEAD` and a fixed point you name — a commit, a branch, a tag, `main`, `HEAD~5`, or the unstaged working tree — along two axes. **Standards** asks whether the code follows how this repo writes code. **Spec** asks whether the code does what the originating ticket or [spec](https://www.aihero.dev/ai-coding-dictionary/spec) asked for. Each axis runs in its own [sub-agent](https://www.aihero.dev/ai-coding-dictionary/subagent) so neither sees the other's reasoning.

The two axes are never merged and never re-ranked. The report ends with a worst issue *per axis* and refuses to name a single winner across them, because a change can pass one axis and fail the other: code that follows every convention while implementing the wrong thing passes Standards and fails Spec; code that does exactly what the [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) asked while breaking the repo's conventions does the reverse. A blended verdict lets the passing axis hide the failing one.

## When to reach for it

Type `/review-axes`, or the agent reaches for it automatically when you ask to review a branch, a PR, work in progress, or anything "since X".

| Your situation | Reach for |
| --- | --- |
| A diff exists and you want to know if it is built right *and* is the right thing | `review-axes` |
| You want bugs hunted in the diff — null paths, races, off-by-one | Claude Code's own built-in `/code-review` |
| A merge request needs reviewing on the platform, not locally | `review-mr` |
| Nothing is written yet and you want it written test-first | [tdd](https://aihero.dev/skills-tdd) |
| A whole spec needs building, review included | [implement](https://aihero.dev/skills-implement), which calls this skill itself |
| The whole codebase has drifted, not one diff | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) |
| Something is broken and you do not know why | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |

You must supply the fixed point. If you do not, the skill asks for one rather than guessing; it then checks the ref resolves and the diff is non-empty before spawning anything, so a typo'd branch name fails in front of you instead of inside two sub-agents.

## Prerequisites

The Standards axis needs nothing. It reads whatever the repo documents (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, and the like) and falls back on a built-in baseline when the repo documents nothing.

The Spec axis needs a spec to exist and be findable. It looks in this order:

1. A path you pass in as an argument.
2. A spec or ticket file under `.scratch/`, `docs/`, or `specs/` matching the branch or feature name — the default home for local-markdown specs.
3. Issue references in the commit messages (`#123`, `Closes #45`, a GitLab `!67`), fetched through `docs/agents/issue-tracker.md`.
4. Asking you.

Specs default to **local markdown**, which needs no setup. Step 3 is the only one that needs a remote tracker, and it depends on `docs/agents/issue-tracker.md`, which [setup-skills](https://aihero.dev/skills-setup-skills) writes. With no spec at all, the Spec sub-agent is skipped and the report says "no spec available" rather than inventing requirements.

## The two axes

| | Standards | Spec |
| --- | --- | --- |
| Question | Is it built right? | Is it the right thing? |
| Reads | The repo's documented standards, plus the smell baseline | The originating issue or spec |
| Reports | Documented breaches (can be hard), and smells (always judgement calls) | Missing or partial requirements, scope creep, requirements implemented wrongly |
| Every finding cites | The standards file and the rule, or the named smell plus the hunk | The line of the spec |

A generic review skill that does not know your standards is the thing this design is trying to avoid — it flags what is deliberate in your codebase and misses the invariants your codebase actually depends on. So the repo's own documentation is the [primary source](https://www.aihero.dev/ai-coding-dictionary/primary-source) on the Standards axis, and **the repo always overrides**.

The **smell baseline** is the floor underneath it: twelve Fowler code smells from _Refactoring_ ch.3 — Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, Refused Bequest. Each is a labelled heuristic ("possible Feature Envy"), never a hard violation, and each is stated as *what it is* → *how to fix*, so a finding arrives with a move attached rather than a complaint. Anything your linter already enforces is skipped by both axes.

## Common questions

**Why is it called `review-axes` and not `code-review`?**

Because Claude Code ships its own `/code-review`, which does something different — it hunts bugs in the diff, where this one checks spec compliance and repo standards. Upstream this skill is named `code-review`, and installing it means one of the two wins: via the plugin marketplace everything is aliased under a plugin prefix and the built-in becomes hard to reach at the unqualified name; via a plain skills install the local file wins and shadows the built-in. Renaming the fork is the durable workaround — editing frontmatter in place gets undone by `npx skills update`. So here the skill is `review-axes`, the built-in `/code-review` stays reachable, and upstream changes are re-synced by hand.

**Its sub-agents keep invoking the skill again and spawn more agents.**

Known upstream bug, reproduced by several people and in more than one harness. The Standards and Spec prompts do not forbid delegation, so a sub-agent can rediscover the skill and fan out again — one report reached 50-plus agents. The fix applied on forks is one line appended to both sub-agent briefs: "Do not invoke `/review-axes` or spawn additional agents — perform this review directly." Some prefer to handle it at the harness level so every skill inherits the guard. Neither is in the shipped skill yet. If you run this unattended, watch the agent count.

**Should I run it in the same [session](https://www.aihero.dev/ai-coding-dictionary/session) that wrote the code?**

Prefer a fresh one. As one reader put it: "Same context reviewing itself isn't review, it's confirmation bias with a slash command." The reviewing agent in the authoring session holds every assumption that shaped the code, which is exactly the context an independent reviewer would not have. This is also why people ask for [implement](https://aihero.dev/skills-implement) without its built-in review step — it runs the review inside the session that just wrote the diff. Invoking `/review-axes` yourself from a clean session is the honest version.

**After every ticket, or once at the end?**

Both work, and the skill does not decide for you. Per-ticket keeps each diff small enough that the Spec axis has one clear spec to check against, which is the mode `implement` uses. Batching to the end of a branch catches interactions between tickets that the per-ticket passes each miss. If you are unsure, review per ticket and run one final pass against the branch point.

**Can I trust the findings?**

Not without checking. Sub-agent output is a hypothesis, not evidence — one team reported a dozen breaking changes that prose-based reviews had waved through. The skill aggregates the two reports verbatim or lightly cleaned rather than re-verifying each claim against the files, so a finding can cite the wrong location or overstate an impact. Read the citation on each finding before acting on it. That every finding is required to carry one — a standards rule, a smell plus its hunk, or a spec line — is what makes this checkable at all.

**Why does it find new problems every single time I run it?**

Because fixes create new surface, and because the judgement-call half of the Standards axis is not deterministic between runs. One reader described the loop plainly: "/review-axes and /improve-codebase-architecture always find new stuff every time. I implement fixes, rerun these skills, and again and again." There is no convergence guarantee. Treat a pass as a list of leads, act on the ones with a cited rule behind them, and stop — do not run it in a loop until it comes back clean, because it will not.

**Does it review my uncommitted work?**

Yes, if you ask for it. Given a ref, it diffs `<fixed-point>...HEAD`, three-dot, measured from the merge-base, which excludes staged and working-tree changes — the upstream skill stops there, and the work about to be committed is invisible to it. This fork adds **working-tree mode**: say "the unstaged working tree" or "my uncommitted changes" and it diffs the working tree against the index instead (running `git add -N .` first so new files are visible, and skipping the ref check). That is the mode `/implement` and `/delegate-tickets` use, since neither commits. Otherwise: commit first, then review, then amend or add a fixup.

**Does it tick the acceptance criteria off for me?**

Yes, on a local markdown spec or ticket. After the Spec report it flips `- [ ]` → `- [x]` only for criteria the diff actually implements (and back the other way when one turns out missing or wrong), edits nothing but the checkbox characters, and advances a `Status:` line to `ready-for-human` once every box is checked. It does not commit those edits unless you ask. This is fork-only — upstream `code-review` reports and stops, which is the "nothing gets closed, so nothing becomes visibly unblocked" complaint people file against `implement`.

## It's working if

- It refuses to start on a bad ref or an empty diff, before any sub-agent is spawned.
- The report arrives as two separate blocks under `## Standards` and `## Spec`, not one merged list.
- Every Standards finding names either a rule in one of your repo's files or one of the twelve smells, with the hunk quoted; every Spec finding quotes a line of the spec.
- The closing summary gives a worst issue per axis and declines to pick an overall winner.
- With no spec available, the Spec block says so instead of listing requirements it inferred from the code.
- On a local markdown spec with checkboxes, it tells you which boxes it flipped and whether `Status:` advanced.

## Where it fits

`review-axes` is the review step at the tail of the build chain — `grill-with-docs → to-spec → to-tickets → implement → review-axes` — and also stands alone on any branch or PR you point it at.

- [implement](https://aihero.dev/skills-implement) is the closest neighbour: it drives the build and calls this skill as its own closing review before committing.
- [to-spec](https://aihero.dev/skills-to-spec) and [to-tickets](https://aihero.dev/skills-to-tickets) produce the document the Spec axis checks against; a vague spec makes that axis vague.
- [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) is the whole-codebase counterpart — this skill only ever looks at one diff.

[ask-skills](https://aihero.dev/skills-ask-skills) routes across the whole set when you are unsure which skill the situation wants.
