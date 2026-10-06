# Allow agents to commit (remove every commit restriction)

Status: ready-for-agent

## Problem Statement

Today agents working with the skills from this repo and the hooks from `claude-hooks` are actively blocked from running `git commit`. The block lives in several layers: the global `git-guardrails` hook refuses any `git commit` (including `git -c … commit`, `git -C <dir> commit`, and even a read-only command that merely contains the pattern, such as a `grep` for it), the `setup-skills` seed deny list adds `git commit` to each project's `permissions.deny`, and the prose of several skills states "never commits" or bans committing outright. The user doesn't want agents to be *asked* to commit, but also doesn't want them to be *prevented* from doing so: if an agent decides to commit, that's fine. Today the restriction gets in the way (a blocked command, a workaround to escape a false positive, rules that forbid more than needed).

## Solution

Remove every restriction on `git commit` from the hooks and the skills, without adding any instruction to commit:

- The `git-guardrails` hook stops blocking `commit`; every other dangerous pattern (push, reset --hard, clean -f, branch -D, checkout ., restore ., rm, push --force) stays blocked.
- `setup-skills` stops seeding commit deny rules in new projects.
- Skills stop saying "never commits" / "do not commit" as a rule. Where the text described a flow that happens not to include a commit, it becomes neutral: the skill does not commit as a step, and doesn't forbid it either.
- In the git-index isolation protocol (`delegate-tickets`, the refactor step of `implement`, the working-tree mode of `review-axes`), the bans on the agent mutating git (`add`, `commit`, `reset`, `stash`, `checkout`, "never anything that moves the index") are removed too, by the user's decision. What the skill itself does (the orchestrator's `git add -A` baseline, the `git stash create` snapshot, reviewing the unstaged tree) stays as the described mechanism, not as a ban on the agent.

## User Stories

1. As a skills user, I want an agent's `git commit` not to be blocked by the global hook, so that an agent that decides to commit can do so.
2. As a skills user, I want `git -c k=v commit` and `git -C <dir> commit` to pass the hook too, so that the global-option forms aren't a loophole in reverse.
3. As a skills user, I want a read-only command that merely contains the commit pattern (a `grep` for it) not to be blocked anymore, so that I don't need to split strings to search the codebase.
4. As a skills user, I want `git push` to stay blocked by the hook, so that loosening commit doesn't open up publishing.
5. As a skills user, I want `git reset --hard`, `git clean -f`, `git branch -D`, `git checkout .`, `git restore .`, `git rm` and `push --force` to stay blocked, so that only commit's restriction changes.
6. As a `claude-hooks` maintainer, I want the hook test suite to assert that commit is allowed, so that a regression that brings the block back fails CI.
7. As a `claude-hooks` maintainer, I want the README to keep describing exactly the blocked patterns, so that the docs don't promise a block that doesn't exist.
8. As a user running `/setup-skills` on a new project, I want the seed deny list to no longer contain `Bash(git commit *)`, `Bash(git -C * commit)` and `Bash(git -C * commit *)`, so that new projects don't inherit the restriction.
9. As a user running `/setup-skills`, I want the Section D explainer to stop saying it blocks commit, so that the question I answer matches what gets installed.
10. As a user running `/setup-skills`, I want the `git-guardrails.md` template written to my project to no longer list commit, so that the project doc matches the deny list.
11. As a user running `/setup-skills`, I want the `### Git guardrails` block written to CLAUDE.md/AGENTS.md to stop citing commit as an example of what's denied, so that the agent doesn't read a restriction that no longer exists.
12. As a user of `/implement`, I want the skill to no longer say "Never make a commit", so that a commit made by the agent isn't a rule violation.
13. As a user of `/implement`, I want the skill to keep generating the Conventional Commits message and the Verdict, so that I can still commit by hand when I want to.
14. As a user of `/implement`, I want the skill not to gain an instruction to commit, so that committing is never asked for.
15. As a user of `/implement`, I want the refactor step to keep describing the `git stash create` snapshot as the way to snapshot, without the ban list (`git add`, `reset`, `stash push`, commit, "never anything that moves the index"), so that the agent isn't restricted.
16. As a user of `/implement`, I want the Review step to keep passing the unstaged working tree to `/review-axes` when the changes are uncommitted, without stating that "nothing here is committed" as a premise, so that the text stays correct if the agent commits.
17. As a user of `/review-axes`, I want the working-tree mode to no longer forbid `git add`, `git commit` or `git reset`, so that the review imposes no restriction on the agent.
18. As a user of `/review-axes`, I want the "Do not commit these markdown edits unless the user asks" rule removed, so that ticking checkboxes doesn't carry a commit restriction.
19. As a user of `/review-axes`, I want the mention of "since neither commits" (about `/implement` and `/delegate-tickets`) to become neutral, so that it doesn't describe a ban that no longer exists.
20. As a user of `/delegate-tickets`, I want the subagent prompt to no longer forbid `git add`, `git commit`, `git reset`, `git stash` or `git checkout`, so that the subagents aren't restricted.
21. As a user of `/delegate-tickets`, I want the orchestrator to keep its index baseline protocol (`git add -A` before the first ticket, with confirmation, and after each ticket), so that the per-ticket diff isolation keeps working in the common case.
22. As a user of `/delegate-tickets`, I want the "/implement never commits" and "Nothing is ever committed" phrases to become neutral descriptions, so that they don't read as a ban.
23. As a user of `/archive-feature`, I want the skill to stop saying "never commits" / "Never commit", so that a commit after archiving isn't forbidden.
24. As a user of `/archive-feature`, I want the skill not to gain an instruction to commit, so that committing stays my call.
25. As a user of `/review-mr`, I want `commit` removed from the list of git commands the skill never runs, so that the restriction disappears; `stash`, `checkout` and `reset` stay, since they weren't the target.
26. As a maintainer of this repo, I want `sync-upstream` (dev-only) to stop saying "Do not commit.", so that the dev-only skill follows the same policy.
27. As a reader of the README and the bucket READMEs, I want the one-liners for `implement` and `archive-feature` to stop saying "Never commits", so that the index describes the real behaviour.
28. As a reader of the docs pages (`docs/engineering/`), I want `implement.md`, `archive-feature.md`, `review-mr.md`, `setup-skills.md` and `review-axes.md` re-synced, so that FAQs and "It's working if" don't promise a missing commit.
29. As a reader of the guides (`docs/guides/en` and `pt-br`), I want the "never commits" / "does not run `git commit`" mentions in `ask-skills` and `implement` updated, so that the guides match the skills.
30. As the `ask-skills` router, I want any "never commits" mention of `/implement` or `/archive-feature` removed or neutralized, so that the router doesn't lie.
31. As a maintainer of this repo, I want the fork's `docs/agents/issue-tracker.md` and the `setup-skills` `issue-tracker-local.md` template to stop saying archive-feature "never commits", so that tracker docs don't carry the restriction.
32. As a maintainer of this repo, I want `fork-divergences.md` updated (the "`implement` Never commits" and "Refactor step … never a commit" rows, plus any archive-feature line that mentions it), so that the next upstream sync defends the new divergence: upstream *instructs* commit, the fork neither instructs nor forbids it.
33. As a maintainer of this repo, I want no new rule telling agents to commit to appear anywhere, so that the change only loosens.
34. As a user who already ran `/setup-skills` in other projects, I want to know those projects keep the old deny rules until I remove them by hand, so that I'm not surprised.
35. As a `claude-hooks` user, I want to know that I need to reinstall the hook (`npx @c0nant/claude-hooks install git-guardrails` after the release) to update the script copied to `~/.claude/hooks-lib/`, so that the change takes effect on my machine.

## Implementation Decisions

- **`claude-hooks`, `git-guardrails` hook:** remove the `commit` pattern (with global-option prefix) from the dangerous-patterns list. Every other pattern stays as is. The block message stays the same.
- **`claude-hooks` release:** the change loosens behaviour, it doesn't break anyone. Commit with a `feat(git-guardrails):` prefix (minor bump), not `!`.
- **`claude-hooks` README:** the hooks table already doesn't list commit; verify and keep it consistent. The `skills` repo README (hooks table in Portuguese) gets the same check.
- **`setup-skills`:** remove the three commit rules from the seed list (text block and jq array), from the `git-guardrails.md` template, from the Section D explainer, and from the `### Git guardrails` sub-block (which cites `commit` as the first example). Leave the "Skip when the deny rules already exist" detection consistent with the new list. Don't add any logic to remove commit rules from projects that already have them.
- **`implement`:** remove "Never make a commit" from the Report step and the "without committing" plus ban list in the refactor step; keep the `git stash create` snapshot and the restore via `git restore --source=<snapshot>` as the procedure. The Review step stays on the unstaged working tree, rewritten so it doesn't assert nothing was committed. Keep the Verdict and Conventional Commits message. No step instructs committing.
- **`review-axes`:** in working-tree mode, remove the "Never run `git add`, `git commit`, or `git reset`…" sentence (keep the `git add -N .` as a procedure step) and neutralize "since neither commits". Remove "Do not commit these markdown edits unless the user asks".
- **`delegate-tickets`:** remove the ban list from the subagent prompt and the "never commits" / "Nothing is ever committed" phrases. The orchestrator's index baseline protocol (initial `git status`, confirmation, `git add -A` before and after each ticket) stays as the mechanism. The subagent prompt keeps explaining that the index holds earlier tickets' work and that the review uses the unstaged tree, as context, without forbidding anything.
- **`archive-feature`:** remove "never commits" from the intro and "Never commit." from the report step. The report stays the same.
- **`review-mr`:** remove only `commit` from the list `stash`, `checkout`, `reset`, `commit` (skill and docs page).
- **`sync-upstream` (dev-only):** remove "**Do not commit.**"; the merge-open-for-review report stays.
- **Prose (READMEs, bucket READMEs, docs pages, guides, `ask-skills`, issue-tracker docs/templates):** rewrite each mention without a blind substitution and without em-dashes (CLAUDE.md rule). Docs pages for `implement`, `archive-feature`, `review-mr`, `setup-skills`, `review-axes` are re-synced per `.agents/writing-docs.md`.
- **`fork-divergences.md`:** rewrite the affected rows. The new divergence: upstream `implement` says "Commit your work to the current branch."; the fork generates the message and leaves committing to whoever wants to, without forbidding it.
- **`plugin.json` / `marketplace.json`:** untouched (no skill added or removed); no need to run `claude plugin validate`.

## Testing Decisions

- A good test checks external behaviour: the hook receives a command's JSON and either blocks (exit 2) or allows (exit 0). It doesn't check the internal pattern list.
- **Agreed seam 1 (single real seam):** `claude-hooks/test/run.sh`, `git-guardrails` sections. `git commit -m x` and `git -c user.email=x -c user.name=y commit -m x` move from `assert_blocked` to `assert_allowed`; add `git -C /tmp commit -m x` and a `grep` containing the pattern as `assert_allowed`. The push, reset --hard, rm, `-C dir push`, `--no-pager reset --hard` and `--git-dir push` assertions stay `assert_blocked`.
- **Skills:** no new seam (prose, no harness). Verification is a sweep in the acceptance criteria: no `SKILL.md`, template, README, docs page or guide keeps a ban on commit (`never commit`, `do not commit`, `nunca commita`, `não faz git commit`, commit in a deny list), and none gains an instruction to commit. `scripts/validate.sh` keeps passing.
- Prior art: the existing `assert_blocked`/`assert_allowed` sections in `test/run.sh`.

## Out of Scope

- Removing deny rules already merged into other projects' `.claude/settings.json`, or the copy of the script already installed at `~/.claude/hooks-lib/` (manual action: reinstall the hook after the release).
- Loosening `push`, `reset --hard`, `clean`, `branch -D`, `checkout .`, `restore .`, `rm` or `push --force` in the hook, or the non-commit `setup-skills` rules.
- Making any skill commit, suggest committing, or gain a "commit mode".
- The `review-mr` restrictions other than commit (`stash`, `checkout`, `reset`), which protect the reviewer's state.
- The `claude-hooks` CI/`release.sh` (they commit as part of the pipeline and are already outside the restriction).
- Historical files in `.scratch/` and `docs/archive/` (specs and tickets from past features).

## Further Notes

- **Accepted risk in `delegate-tickets`:** without the bans on subagents, a subagent that runs `git add`, `git commit`, `git reset` or `git stash` can mix or hide earlier tickets' work, and the next ticket's review (via unstaged tree) can come back empty or see someone else's diff. The user chose to loosen anyway; the orchestrator's baseline protocol keeps working when nobody touches the index. Likewise, if `implement` commits before Review, the unstaged-tree diff comes back empty; since no skill instructs committing, that only happens by the agent's choice.
- The `git -C * commit` rules in `setup-skills` exist in pairs (bare and with args): remove both.
- When the hook is reinstalled, searches like a `grep` that mention the pattern stop needing string splitting.
