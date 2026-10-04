# archive-feature: close a finished feature and move it to the archive

Status: ready-for-agent

## Problem Statement

I run features through `grill-me` → `to-spec` → `to-tickets` → `implement`. When everything has been implemented, the feature folder in `.scratch/<feature-slug>/` is left as it is: the tickets stay `ready-for-human`, the spec stays `ready-for-agent`, and nothing says the work is over. I then close everything by hand and move the folder somewhere to keep it as history until the deploy.

Three things make that manual step costly:

1. **There is no "finished" status.** After `ready-for-human` the vocabulary ends, so the files cannot say a ticket is done, and nobody can tell from the files alone which features are closed.
2. **Checking that a feature is really complete is tedious.** I have to open every ticket to see whether its status and its checkboxes say it was finished, before I trust that it can be archived.
3. **`.scratch/` is not a safe place to keep history.** It is wiped from time to time, so a finished feature kept there until the deploy can be lost.

## Solution

A new user-invoked skill, `archive-feature`, that closes the loop of the flow. I call it with one feature (by folder name or by the path to its spec) or with no argument. With no argument it reads every feature under `.scratch/`.

For each feature it checks, from the files only, whether the work is complete. It shows me a table of what is ready and what is missing, and after a single confirmation it closes the ready ones. Closing means setting their spec and tickets to a new `done` status. It then moves each one whole, with `git mv`, to `docs/archive/<feature-slug>/`. An incomplete feature is archived only when I pick it by name, and the spec then gets a dated note listing what was left out. The skill never ticks a checkbox and never commits.

## User Stories

1. As a maintainer, I want to run one command after `implement` finishes, so that closing a feature stops being a manual chore.
2. As a maintainer, I want to pass a feature by its folder name, so that I can close exactly the one I just finished.
3. As a maintainer, I want to pass a feature by the path to its spec, so that I can copy the path I already have at hand.
4. As a maintainer, I want to run the command with no argument and have it read every feature under `.scratch/`, so that I do not have to remember which ones are finished.
5. As a maintainer, I want the skill to treat a folder as a feature only when it has a spec, so that tool output folders (like a tech-debt map) are never archived by mistake.
6. As a maintainer, I want folders without a spec listed as ignored in the summary, so that I can see they were looked at and deliberately skipped.
7. As a maintainer, I want a feature with tickets to count as ready only when every ticket is `ready-for-human` or `done`, so that a ticket still waiting for an agent is never closed by accident.
8. As a maintainer, I want a feature with tickets to count as ready only when every checkbox in its tickets is ticked, so that half-finished acceptance criteria are caught.
9. As a maintainer, I want the spec's own status ignored when judging readiness, so that a spec still saying `ready-for-agent` (it never moves in the current flow) does not block an otherwise finished feature.
10. As a maintainer, I want a feature without tickets (implemented straight from the spec) to trigger a direct question about whether it was implemented, so that nothing is closed on a guess when the files cannot tell.
11. As a maintainer, I want the skill to only read checkboxes and never tick them, so that the archive shows exactly what was done, not what the closing step assumed.
12. As a maintainer, I want a summary table of every feature with its state (ready, or what is missing), so that I can decide at a glance.
13. As a maintainer, I want one confirmation to archive all ready features at once, so that the common case (one or two finished features) is quick.
14. As a maintainer, I want an incomplete feature to be archived only if I name it explicitly, so that leaving something out is always a decision I made.
15. As a maintainer, I want the list of what is missing shown for each incomplete feature, so that I can choose between finishing it and archiving it anyway.
16. As a maintainer, I want an incomplete feature I chose to archive to get a dated note under `## Comments` at the end of its spec listing what was left out, so that whoever reads the archive later knows the gaps were deliberate.
17. As a maintainer, I want the incomplete tickets of such a feature to keep their current status, so that the archive tells the truth about which tickets were really finished.
18. As a maintainer, I want the spec and every ready ticket set to `done`, so that the files themselves say the work is over.
19. As a maintainer, I want `done` to be part of the shared triage vocabulary, so that other skills (for example a future check of `Blocked by` before starting a ticket) can rely on it.
20. As a maintainer, I want each closed feature moved whole to `docs/archive/<feature-slug>/`, keeping its internal layout, so that the spec, tickets, backlog and any handoff stay together.
21. As a maintainer, I want the move done with `git mv`, so that the files keep their history.
22. As a maintainer, I want `docs/archive/` and its README (the existing archive convention) created when they are missing, so that the skill works in a repo that never set the archive up.
23. As a maintainer, I want the skill to stop on a feature whose destination folder already exists, warn me, and carry on with the others, so that an older archive is never overwritten or merged.
24. As a maintainer, I want the skill to leave the commit to me, so that I review the moved and edited files before they enter history.
25. As a maintainer, I want the skill to refuse with a clear message when the repo uses a remote tracker (GitHub, GitLab, Linear), so that it never pretends to archive issues it cannot move.
26. As a maintainer, I want the skill to be user-invoked only, so that no agent ever archives a feature on its own, matching the existing rule of the archive convention.
27. As a maintainer, I want a feature folder that was already archived to no longer appear in a no-argument run, so that each run only shows what is still active.
28. As a maintainer, I want `ask-skills` to route "I finished implementing, now what?" to `archive-feature`, so that the router shows the last step of the flow.
29. As a user installing these skills, I want `archive-feature` listed in the README and shipped in the plugin, so that I can find and install it like the other daily-flow skills.
30. As a user installing these skills, I want a docs page for `archive-feature`, so that I know when to reach for it and how to tell it worked.
31. As a user setting up a new repo with `setup-skills`, I want the `done` status in the triage labels file it generates, so that `archive-feature` works there without manual edits.
32. As the maintainer of this fork, I want the new skill recorded in the fork divergence ledger, so that the next upstream sync does not drop it.

## Implementation Decisions

- **New skill `archive-feature`** in the `engineering/` bucket (promoted). User-invoked: `disable-model-invocation: true` in the frontmatter and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, per `.agents/invocation.md`.
- **Tracker scope**: local markdown only. The skill resolves the tracker the same way the other skills do (`docs/agents/issue-tracker.md`); for any remote tracker it says it does not apply and stops.
- **Argument**: optional. Accepts a feature folder name or a path to a `SPEC.md`. No argument means every folder directly under `.scratch/`.
- **What counts as a feature**: a folder under `.scratch/` that contains `SPEC.md`. Others are reported as "ignored (no SPEC.md)".
- **Readiness rule**:
  - With tickets: every ticket's `Status:` is `ready-for-human` or `done`, and every checkbox in every ticket is ticked. The spec's status does not count.
  - Without tickets: the skill asks the user whether the feature was implemented.
- **Flow**: read → summary table (feature, ready / list of what is missing, ignored folders) → one confirmation archives every ready feature → incomplete features are archived only when named explicitly by the user.
- **Closing a feature**: set `Status: done` on the spec and on every ticket that met the readiness rule. Never tick or untick a checkbox. Tickets that did not meet it keep their status.
- **Incomplete feature archived anyway**: append a dated entry under a `## Comments` heading at the bottom of the spec (create the heading if missing), listing the tickets and unchecked items that were left out. This follows the existing "comments append under `## Comments`" convention of the local tracker.
- **Move**: `git mv .scratch/<feature-slug> docs/archive/<feature-slug>`, whole folder, layout untouched (spec, tickets, backlog, handoffs, post-deploy notes). If `docs/archive/` or its README is missing, create them with the convention content already published in the `setup-skills` guide ("Optional: archive finished features"). If `docs/archive/<feature-slug>/` already exists, skip that feature with a warning and continue with the rest.
- **No commit**: the skill stages via `git mv` and edits files; committing stays with the user. The final report lists what was archived, what was skipped and why.
- **New triage role `done`**: added to the triage vocabulary in this repo's `docs/agents/triage-labels.md` and to the template `setup-skills` ships, with the meaning "work finished and accepted; set by `archive-feature`". The canonical list grows from five roles to six, so any prose that says "five canonical roles" is updated.
- **Archive convention**: the local tracker template shipped by `setup-skills` and this repo's `docs/agents/issue-tracker.md` gain the pointer to `docs/archive/<feature-slug>/` for finished features, now naming `archive-feature` as the way to get there.
- **Repo wiring** (promoted-bucket invariants): entry under **User-invoked** in the top-level `README.md` and in `skills/engineering/README.md`; entry in `.claude-plugin/plugin.json`'s `skills` array (then `claude plugin validate . --strict`); docs page `docs/engineering/archive-feature.md` following `.agents/writing-docs.md`; `ask-skills` updated so the flow ends with `archive-feature`; a row in `.agents/fork-divergences.md` with a grep phrase.
- **Writing style**: no em-dashes, per the repo rule.

## Testing Decisions

- A good test here checks what the user sees and what ends up on disk, never the wording of the skill: which folders moved, which `Status:` lines changed, which checkboxes stayed as they were, what the summary table and final report said.
- **Seam**: one end-to-end seam, a throwaway git repo with a fixture `.scratch/` where the skill is invoked. Fixture features cover: fully ready with tickets; ticket still `ready-for-agent`; ticket with an unchecked box; feature without tickets; folder without `SPEC.md`; destination already present in `docs/archive/`; repo without `docs/archive/`.
- Checks per case: ready feature moved with `git mv` and all statuses `done`; incomplete feature untouched unless named, then moved with a `## Comments` note and incomplete tickets keeping their status; no checkbox changed anywhere; ignored and colliding folders reported and left in place; nothing committed.
- One extra run with a remote tracker configured, to check that the skill stops with its message.
- Prior art: skills in this repo are verified by running them on a real or fixture workspace and reading the result (the skill-flow-improvements tickets were accepted that way); there is no automated test suite for `SKILL.md` files. `claude plugin validate . --strict` covers the manifest change.

## Out of Scope

- Cleaning the archive after the deploy: the maintainer deletes archived folders by hand for now.
- Remote trackers (closing GitHub, GitLab or Linear issues).
- Committing or pushing.
- Ticking checkboxes or editing ticket content other than the `Status:` line.
- Making other skills (for example `implement` or `delegate-tickets`) read the `done` status; that is backlog item 10's job.
- Moving the spec status during the flow (for example `to-tickets` or `implement` updating it).

## Further Notes

- The existing archive convention says "an agent never archives on its own". That is why the skill is user-invoked: the human calling it is the decision.
- The `done` role also unblocks part of backlog item 10 in `.scratch/skill-flow-improvements/BACKLOG.md` ("there is no finished status after `ready-for-human`").
- Decided in a grilling session on 2026-10-04.
