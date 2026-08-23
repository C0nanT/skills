## What it does

`review-mr` reviews **someone else's** merge request (a GitLab MR, a GitHub PR, or two local branches) along four axes: **Correctness**, **Security**, **Performance**, and **Design**. It checks the change against the acceptance criteria the task claims to deliver, opens the report with a verdict (approve, approve with comments, or request changes, and why), and writes the whole thing to a local markdown file under `.scratch/reviews/`.

Every finding has to survive one rule: it carries a `file:line` anchor **and** the concrete execution path that produces the problem, the input, the state, or the call sequence. If that path cannot be written, the finding does not go in the file. That single constraint is what separates this from a generic review bot, because it kills style preference dressed as a bug, "consider adding tests", and theoretical security warnings with no reachable input. An empty report is an allowed outcome.

## When to reach for it

You invoke this by typing `/review-mr`, and the agent will not reach for it on its own.

| Your situation | Reach for |
| --- | --- |
| Someone else's MR or PR is waiting on your review | `review-mr` |
| Your own diff needs checking against the repo's standards and the spec it came from | [review-axes](./review-axes.md) |
| You want bugs hunted in the current diff, no MR involved | Claude Code's own built-in `/code-review` |
| The whole codebase has drifted, not one merge request | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) |

Pass the MR as a URL, a number (`!123`, `#456`, or bare `123`), or nothing at all to review the one for the current branch. For two local branches you must name both: the source and the target are what simulate the MR, and the skill stops and asks rather than guessing `main`.

## Prerequisites

A **local clone of the repo the MR belongs to**, in all three modes. The review deliberately reads whole files and the callers around them, not just the diff, so a working copy has to exist. Half of what the skill is looking for is invisible in an isolated hunk: a function identical to one three modules away, a contract broken in a caller the MR never touched, a null now reachable because a guard disappeared upstream.

Beyond that: `glab` for GitLab mode, `gh` for GitHub mode, neither for local mode. The skill never touches your git state, no `stash`, `checkout`, `reset`, or `commit`, so a dirty working tree is reported and then ignored.

## Declared intent, and the questions the diff cannot answer

The MR's title, description, and commit list are the **declared intent**, and they are what separate a bug from a deliberate choice. An MR that deletes a validation looks like a null waiting to happen, until the description says the validation moved to the gateway. Then the finding either dies, or it becomes a verifiable one: "the description says validation moved to the gateway, but `gateway.ts` has no such check."

The intent is rarely complete, so the skill turns it into a checklist of acceptance criteria and then **asks you what the diff cannot answer**, before it judges anything. At most five questions, in one batch, and only ones whose answer changes the review: whether a finding is a bug or a choice, whether a criterion is met, whether the verdict flips. Each question says what its answer decides, so you know why you are being asked. Anything you do not answer becomes an **Open questions** entry in the file for you to take to the author, and the criteria it gated are marked `❓ Unverifiable` rather than guessed.

## The verdict, and what it is derived from

The report opens with the verdict so the reader knows in one line whether this merges. It is mechanical, derived from what survived the cut rule, never a mood:

| Verdict | Condition |
| --- | --- |
| **Request changes** | A Blocker, or a criterion the MR claimed and did not deliver. |
| **Approve with comments** | Should-fix items or partially met criteria, nothing that holds the merge. |
| **Approve** | Nothing above Consider, every criterion met. |
| **Blocked on answers** | A question that decides one of the rows above went unanswered. Not "no", but "not yet knowable". |

Severity is defined by consequence, never inherited from the axis: a security finding can be a Consider (a verbose log on an internal-only endpoint), and a design finding can be a Blocker (two copies of a rule that have already diverged, one of them wrong). Below the findings sits a capped list of at most five **suggestions**, the only part of the file exempt from the cut rule, each anchored and each naming its payoff. A suggestion never affects the verdict; if it should have, it was a finding and it was mislabelled.

The verdict is the reviewer's reading, not a merge decision. You still own the call.

## Common questions

**Why does it write a file instead of telling me in the chat?**

Because a review of someone else's code is working material you read top-down, come back to after the author pushes, and quote from selectively into the MR thread. The file lands in `.scratch/reviews/`, which is normally gitignored, so it is your scratch rather than a project artifact. The chat gets one line: the verdict and the path.

**Does it post comments on the MR?**

Never automatically. Ask it to post, and it shows you each comment's exact text and target and waits for approval before sending. This is code belonging to another person in a conversation between people: a false positive posted publicly is a social cost that lands on you, and a bot dumping fifteen comments on an MR is what makes teams switch this kind of tooling off.

**What happens when I run it again after the author pushes fixes?**

It appends a new `## Review N` section rather than overwriting, and opens it by reconciling every prior finding as fixed, still present, or no longer applicable. On a second pass the most valuable information is not the new findings, it is which of the old ones survived. The verdict, the criteria table, and the open questions sit at the top of the file and are rewritten in place, because they describe the MR as it stands now.

**Why only two reviewers when there are four axes?**

Cost. The session itself takes Correctness and Security, since it already holds the diff, the intent, and the file list. One [sub-agent](https://www.aihero.dev/ai-coding-dictionary/subagent) on a small model takes Performance and Design, because hunting a duplicate implementation means grepping modules the MR never touched, and that fills a [context window](https://www.aihero.dev/ai-coding-dictionary/context-window) with files nobody needs afterwards.

**What if the MR is huge?**

It is reviewed anyway. The skill reports the size first (files changed, lines added and removed) and then reviews all of it. It never silently truncates, because a review that quietly skipped half the diff reads as a pass.

## It's working if

- It asks you a handful of pointed questions before reviewing anything, and each one says what the answer decides.
- The file opens with a verdict and two or three lines naming the specific items that drive it.
- The acceptance-criteria table has an anchor in the evidence column, not "looks implemented".
- Every finding names a file and line plus the path that gets there, and nothing reads as generic craft advice.
- Coming back empty is a result it will actually report, rather than always finding something.
- Your git state is untouched afterwards, dirty working tree included.
- The chat says one line and the substance is in the file.

## Where it fits

`review-mr` is a reach-for-it-anytime standalone: it belongs to reviewing other people's work, not to the build chain.

- [review-axes](./review-axes.md) is the mirror image and the one it is most confused with: that one judges **your** diff against the repo's standards and the spec you were given, this one judges **someone else's** where nobody has told you what the code was supposed to do.
- Claude Code's built-in `/code-review` hunts bugs in a diff without the MR framing, the criteria check, or the verdict.

[ask-skills](./ask-skills.md) routes across the whole set when you are unsure which skill the situation wants.
