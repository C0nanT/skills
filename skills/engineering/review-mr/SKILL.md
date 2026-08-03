---
name: review-mr
description: Review someone else's merge request for bugs, security, performance and design, and write the findings to a local markdown file.
disable-model-invocation: true
---

# Review MR

Review **another developer's** merge request and write the findings to a local markdown file.

This is not `/review-axes`. That one reviews *your* code against the repo's standards and the originating spec. This one reviews *someone else's* code along four axes — **Correctness**, **Security**, **Performance**, **Design** — where nobody has told you what the code was supposed to do beyond what the MR itself claims.

Two reviewers only, deliberately: this session covers Correctness + Security, and a single sub-agent covers Performance + Design. Keeping it to two is a cost decision — respect it.

Everything this skill writes is in **English**, whatever language the MR or the surrounding conversation is in.

## Process

### 1. Resolve the input

Three modes. Detect which by looking at `git remote get-url origin`:

| Mode | Detection | Diff source |
| --- | --- | --- |
| **GitLab** | remote host contains `gitlab` | `glab mr` |
| **GitHub** | remote host contains `github` | `gh pr` |
| **Local** | neither, or the user named two branches | `git diff` between two branches |

The identifier the user passes may be a full URL, a number (`!123`, `#456`, or bare `123`), or nothing at all — with nothing, use the MR/PR for the current branch (`glab mr view` / `gh pr view` with no argument resolve this).

**Local mode requires both branches.** The user must name a source branch and a target branch — that pair is what simulates the MR. If either is missing, stop and ask. Do not guess the target from `main`.

**A local clone is a hard prerequisite, in all three modes.** This review reads whole files, not just the diff (see step 3), so there must be a working copy. If the current directory is not the repo the MR belongs to, stop and say so.

Fetch the branch under review, then pin the fixed point:

```
git fetch origin <source-branch>
git merge-base origin/<target-branch> origin/<source-branch>
```

The diff is always three-dot against the merge-base — `git diff <merge-base>...<source>` — so changes the target branch made in the meantime don't show up as the author's work.

Before going further, confirm the diff is non-empty and report its size (files changed, lines added/removed). **A large MR is reviewed anyway** — say how big it is, then review all of it. Never silently truncate; a review that quietly skipped half the diff reads as a pass.

**Leave the user's git state alone.** If the working tree is dirty, say so and carry on — never `stash`, `checkout`, `reset`, or `commit`. Everything here reads through `git diff` and `git show` against refs.

### 2. Gather the declared intent

Pull the MR title, description, and commit list (`glab mr view <id>` / `gh pr view <id>`, plus `git log <merge-base>..<source> --oneline`).

This is what separates a bug from a deliberate choice. An MR that deletes a validation looks like a null-pointer waiting to happen — until the description says the validation moved to the gateway. Then the finding is either dead, or it becomes a *verifiable* one: "the description says validation moved to the gateway, but `gateway.ts` has no such check."

In local mode there is no MR, so the intent comes from `git log` on the branch and, if one exists, a spec under `.scratch/`. When there is nothing, record **"no declared intent"** in the report header rather than inventing one — and hold findings to a higher bar, since you cannot tell deliberate from accidental.

### 3. Locate the standards, and read past the diff

Find whatever the **target repo** documents about how its code should be written: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`. Collect the paths — the sub-agent reads them itself.

Both reviewers read **whole files, and the callers around them**, not just the diff. Half of what this skill exists to find is invisible in an isolated hunk: a function identical to one that already lives three modules away, a contract broken in a caller the MR never touched, a null now reachable because a guard disappeared upstream.

### 4. Review — this session takes Correctness + Security

Do this work yourself, in this session. You already hold the diff, the intent, and the file list, so the marginal cost is near zero.

**Correctness** — logic that produces a wrong result, unhandled errors and edge cases, null/undefined now reachable, off-by-one and boundary handling, broken contracts with existing callers, concurrency and ordering assumptions, error paths that swallow failures, tests that assert the wrong thing.

**Security** — injection (SQL, command, template, path), authentication and authorization gaps (especially a new endpoint that inherits no guard), secrets or credentials in code or config, sensitive data reaching logs or error responses, unvalidated input crossing a trust boundary, unsafe deserialization, permissive CORS or cookie flags.

Apply the cut rule in step 6 as you go. A finding you cannot ground in a concrete execution path does not get written down.

### 5. Review — one sub-agent takes Performance + Design

Spawn **exactly one** sub-agent (`Agent` in Claude Code, `Task` in Cursor), `general-purpose` / `generalPurpose`.

**Pick the model by host** — this review is meant to be cheap:

| Host | Model | Notes |
| --- | --- | --- |
| **Claude Code** | `model: haiku`, `effort: medium` | Haiku only on Claude Code. |
| **Cursor** | `model: claude-4.5-haiku-thinking` | Task rejects `composer-2.5` (Standard). The only Composer slug allowed is `composer-2.5-fast` (~6× cost) — skip it. |

The sub-agent gets the wide sweep on purpose: hunting a duplicate implementation means grepping modules the MR never touched, and that fills a context window with irrelevant files. Isolating it there keeps this session clean for the conversation afterwards.

Give the sub-agent: the diff command, the merge-base, the commit list, the MR title and description, the paths of the standards files from step 3, the smell baseline below **pasted in full**, and the severity scale and cut rule from step 6 **pasted in full**. It has no other access to any of it.

Its brief:

> Review this merge request along two axes, reading whole files and callers — not just the diff.
>
> **Performance** — N+1 queries, queries without a usable index, loops that are quadratic over data that grows, synchronous or blocking work on a hot path, allocation inside tight loops, work repeated per-item that could be hoisted or batched, unbounded memory growth, missing pagination.
>
> **Design** — duplicated logic (including logic that already exists elsewhere in the repo, outside this diff), SOLID violations at the module level (a module with several reasons to change, a dependency pointing from policy to detail, an interface forcing implementers to refuse most of it), plus the smell baseline below.
>
> Two rules bind the baseline: **the target repo's documented standards override it** — where a documented standard endorses something the baseline would flag, suppress the finding; and every baseline hit is **a judgement call**, never a hard violation. Skip anything the repo's tooling already enforces.
>
> Apply the severity scale and cut rule exactly as given. Report findings only. No summary, no praise, no suggestions to "add tests" without a named case that is missing.

**Smell baseline** (Fowler, *Refactoring* ch.3) — each reads *what it is* → *how to fix*:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one place. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs nothing in the MR has. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 6. Severity and the cut rule

**Severity is defined by consequence, never inherited from the axis.** A security finding can be `Consider` (a verbose log on an internal-only endpoint); a design finding can be a `Blocker` (two copies of a rule that have already diverged, and one is wrong). If the axis dictated the label, the label would carry no information.

| Level | Definition |
| --- | --- |
| **Blocker** | In production this breaks, corrupts data, or exposes something. You can describe the execution path that gets there. |
| **Should fix** | Doesn't break today, but the cost compounds: a fragile contract, duplication that will diverge, a query that degrades at real volume. |
| **Consider** | A legitimate improvement with a nameable impact, which the author can decline at no cost. |

**The cut rule.** Every finding carries evidence: a `path/to/file.ext:42` anchor *and* the concrete path that produces the problem — the input, the state, or the call sequence. **If you can't write that path, the finding doesn't go in the file.**

This is the filter that keeps the skill usable. It kills the three plagues of automated review: style preference dressed as a bug, generic "consider adding tests", and theoretical security warnings with no reachable input.

**An empty report is a valid result.** If nothing survives the cut, the file says so and that's the review. A reviewer that always finds something isn't rigorous, it's noisy.

### 7. Write the file

One artifact, no report in the chat. Path: `.scratch/reviews/<slug>.md`, where the slug is determined by mode:

| Mode | Slug |
| --- | --- |
| GitLab | `gitlab-mr-<id>.md` |
| GitHub | `github-pr-<id>.md` |
| Local | `local-<source>--<target>.md` (`/` in branch names becomes `-`) |

`.scratch/` is where this repo's skills already keep working material, so it's normally gitignored. A review of someone else's code is your scratch, not a project artifact — it shouldn't be committed.

Structure:

```markdown
# Review — <MR title>

- **Source**: <mode> · <identifier or branch pair>
- **Head**: <short sha> · **Merge-base**: <short sha>
- **Size**: N files, +X/-Y
- **Declared intent**: <one line from the MR description, or "none">

## Review 1

### Blocker
- `path/to/file.ext:42` — **What is wrong.** Impact: the concrete path that gets there. Fix: one line.

### Should fix
...

### Consider
...
```

Order findings by severity, not by axis — you read top-down and stop when the return drops off. Drop a severity heading entirely when it's empty.

Then say **one line** in the chat: the path to the file. Nothing else — no summary, no findings pasted back. The file is the deliverable.

### 8. Re-review

When the file already exists, the author has pushed fixes and wants another look. **Append**, never overwrite.

Read the previous `## Review N` section first, then re-review at the new head. Open the new section by reconciling every prior finding:

```markdown
## Review 2 — <new short sha>

### Previous findings
- ✅ **Fixed** — `file.ext:42` <prior finding, one line>
- ❌ **Still present** — `file.ext:88` <prior finding, one line>
- ➖ **No longer applies** — <prior finding>: the code it pointed at is gone.

### Blocker
...
```

On a second pass the most valuable information isn't the new findings — it's *which of the old ones survived*. Lead with that.

## Posting to the MR

**Never post automatically.** The skill ends at the file.

If the user asks to post ("post those three on the MR"), then for each comment show the exact text and its target (file + line) and wait for approval before sending — `glab mr note` / `gh pr review`. Send only what they approved.

This is code belonging to another person, in a conversation between people. A false positive posted publicly isn't a software bug, it's a social cost that lands on the user. And a bot dumping fifteen comments on an MR is precisely what makes teams switch this kind of tooling off.
