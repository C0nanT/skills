---
name: ask-skills
description: Ask which skill or flow fits your situation. A router over the skills in this repo.
disable-model-invocation: true
---

# Ask Skills

You don't remember every skill, so ask.

Before stating what a skill does or recommending a step be skipped, read that skill's SKILL.md: the summaries here are for orientation only.

A **flow** is a path through the skills. Most paths run along one **main flow**, and an **on-ramp** merges onto it. Everything else is standalone.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built.

1. **`/grill-with-docs`** sharpens the idea by interview. Start here whenever you are **working in a working directory**: it's stateful, retaining what it learns in `GLOSSARY.md` and ADRs. (No working directory? Use `/grill-me` instead, covered under Standalone. Both run the same `/grilling` primitive; `grill-with-docs` is the one that leaves a paper trail, which makes it the better of the two whenever a repo is there to leave it in.)
2. **Branch: can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see), detour through a prototype, bridged by **`/handoff`** in both directions (a prototype lives in its own directory, which is exactly what `/handoff` is for; see Phase boundaries):
   - **`/handoff`** out, then open a fresh session against that file,
   - **`/prototype`** to answer the question with throwaway code,
   - **`/handoff`** back what you learned, and reference it from the original idea thread.
3. **Branch: is this a multi-session build?**
   - **Yes** → **`/to-spec`** (turn the thread into a spec), then **`/to-tickets`** to split it into tracer-bullet tickets, each declaring its **blocking edges**. Then work the tickets one of two ways:
     - **`/implement`** per ticket, **`/clear`ing context between each one**. On a local tracker that's one file per ticket under `.scratch/<feature>/tickets/`, worked blockers-first by hand; on a real tracker the edges become native blocking links, so any ticket whose blockers are done can be grabbed. Each ticket is self-contained, so the last one's context is disposable. (`/delegate-tickets`, under Standalone, runs this loop unattended, one subagent per ticket.)
     - **`/implement-spec`** for the whole spec in one run. It reads the tickets as a **task graph**, runs implementer subagents across the ready **frontier** in parallel, and lands everything on one **integration branch**, then runs one `/review-axes` over it. Reach for it when you'd rather orchestrate the build than drive each ticket yourself.
   - **No** → **`/implement`** right here, in the same context window.

   Either way, **`/implement`** builds each ticket by driving **`/tdd`** internally: one red-green slice at a time, runs the full suite, makes one refactor pass over its own diff (undone if the suite goes red), then closes out by running **`/review-axes`**, a two-axis review (Standards + Spec) of the diff, and ends by committing the work to the current branch. Reach for **`/tdd`** on its own when you just want to build a concrete behaviour test-first without a full spec, and **`/review-axes`** on its own whenever you want to review a branch against a fixed point. `/review-axes` is for **your own** work, it judges the diff against the standards you follow and the spec you were given. Reviewing **someone else's** merge request is a different job: see `/review-mr` under Standalone.

   When the work goes up as a pull request, **`/pr`** shapes the body: the smallest visual that shows the change, before/after evidence that it works, and a one-way or two-way door call. It's model-invoked, so the agent reaches for it whenever it writes a PR.

4. **`/retro`** looks back once a build is done, and especially after one that went sideways. It reads the session and suggests changes to the agent's **environment**, not the code: navigation pointers, automated checks, the coding standards `/review-axes` enforces, steering files, tooling. Mechanical mistakes become deterministic checks; judgement calls become coding standards. The next build then starts from a better environment.

5. **`/archive-feature`** closes the loop once everything is implemented. On a local tracker it checks from the files that every ticket is `ready-for-human` (or `done`) with every checkbox ticked, shows a summary table, and after one confirmation sets the spec and tickets to `done` and moves the feature whole with `git mv` from `.scratch/` to `docs/archive/<feature-slug>/`. Pass a feature name or spec path, or nothing to scan every feature under `.scratch/`. An incomplete feature is archived only when you name it, with a dated note in its spec listing what was left out. It never ticks a checkbox. Reach for it when you ask "I finished implementing, now what?". It does not apply to a remote tracker.

### Context hygiene

Keep steps 1–3 in **one unbroken context window** (don't compact or clear until after `/to-tickets`) so the grilling, spec, and tickets all build on the same thinking. Each `/implement` then starts fresh, working from the ticket. Run `/retro` in the session it's looking back on, before you clear; after clearing, point it at that session's log instead.

The limit on this is the **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: the window (~150k tokens on state-of-the-art models) within which the model still reasons sharply. If a session approaches it before `/to-tickets`, don't push on degraded; `/compact` at the nearest phase boundary and carry on (see Phase boundaries).

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **A huge, foggy effort: a greenfield project or a huge feature build, too big for one session** → **`/wayfinder`**, the most cognitively demanding flow here. When the way from here to the destination isn't visible yet, it charts a **shared map** of **decision tickets** on the issue tracker and resolves them one at a time, producing **decisions, not deliverables**, until the fog is pushed back and the way is clear. Where **`/grill-with-docs`** sharpens an idea you can hold in one session, wayfinder is for the idea you can't, and it's slower and denser, so save it for exactly that, never a well-scoped feature.

  When the map clears, **it hands off, it doesn't build**: merge onto the main flow at **`/to-spec`**, which collapses the map's linked decisions into a buildable plan, then `/to-tickets` and `/implement` as usual. Looping the map straight into `/implement` skips that collapse and throws the linked detail away, so go straight to `/implement` only when the effort turned out genuinely small. Along the way, its **research** tickets resolve in parallel through `/research` subagents, so reading legwork doesn't wait on you.

## Codebase health

Not feature work, just upkeep.

- **`/improve-codebase-architecture`**: run whenever you have a spare moment to keep the codebase good for agents to operate in. It surfaces **deepening opportunities**; picking one *generates an idea* you can take into the main flow at `/grill-with-docs`.

- **`/tech-debt-map`**: the wider, colder survey, taken **one module at a time**. It works out how the project divides into modules (declaring the partition itself when the project doesn't), asks you which one to review and shows how long since each was last looked at, then sweeps that module across every axis (architecture, code, business rules, maintainability, testability, performance, security) and leaves a **debt map**: at most 10 evidence-backed findings ranked by payoff against blast radius, then a three-phase incremental plan. It is a **diagnosis, not a refactor**, and changes no code, though it does keep a committed review index at `docs/tech-debt/README.md` so a module nobody has audited in eight months is visible. Where `/improve-codebase-architecture` hunts one class of problem and ends in a grilling session about a single candidate, this one ends in a file you work through over weeks and re-run against to see what moved. Its rows feed `/to-spec` and then `/to-tickets`; a row whose blast radius is Systemic feeds `/improve-codebase-architecture` instead.

## Phase boundaries

A **phase** is a chunk of work inside a session: the grilling, the implementation, the QA. At the **boundary** between two of them you have five options, and picking between them is the fuzziest decision in this whole map:

- **Continue**: stay put. Costs nothing, loses nothing.
- **`/clear`**: empty the window, when nothing here matters to what's next.
- **`/handoff`** writes a portable markdown file. Narrow: only for a **new harness**, a **new directory**, a **colleague**, or forking a side task **mid-phase**. What it buys is portability.
- **Subagent**: send a tightly-scoped task to its own window and get a report back.
- **`/compact`** compresses this context and seeds a fresh session with it. The **default**, at the bottom of the tree rather than the first reach.

Read [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) for the ordered tree: the five questions, the reasoning behind each branch, and why the primary-source cost makes **Continue** the one to rule out first. Make the decision **at** a boundary; mid-phase, continue or split the rest into subagents.

## Standalone

Off the main flow entirely.

- **`/grill-me`**: the same relentless interview as `/grill-with-docs`, but **stateless**: it saves nothing locally and builds no `GLOSSARY.md`. Reach for it when you are **not working in a working directory** (sharpening a plan, a design, a piece of writing, anything with no repo under it). If you are in a working directory, use `/grill-with-docs` instead: it runs the same interview and leaves a paper trail, so it is strictly the better one.
- **`/grilling`**: the interview primitive itself: rounds, the frontier, facts are the agent's job and decisions are yours. `/grill-me` and `/grill-with-docs` are the two named ways in, and `/wayfinder` and `/improve-codebase-architecture` all run it internally. Reach for it directly only when you want the interview with no wrapper around it.
- **`/prototype`**: a small, throwaway program that answers one design question: does this state model feel right, or what should this UI look like. Throwaway is a constraint on how the code is written, not a promise to destroy it: the answer folds into the real code, and the prototype itself is kept as a **primary source** on a `prototype/<name>` branch out of main, pointed at from the implementation issue. It's the detour in step 2 of the main flow, but reach for it any time a design question is hard to settle on paper.
- **`/research`**: delegate reading legwork to a **background agent**: it investigates a question against **primary sources**, then leaves a cited Markdown file in the repo. Keep working while it reads. The file it produces is something to take *into* the main flow at `/grill-with-docs`, research feeds the thinking, it doesn't replace it.
- **`/frontend-handoff`**: the change is shipped and another team consumes it. Reads the spec and diff, then emits a pasteable block whose **verdict**, must change / should change / nothing required, is the one thing the frontend dev needs first. Runs after `/implement`, and answers "does the front have to touch anything?" without a meeting. It hands over context only; the frontend work itself is a separate task in their repo.
- **`/to-questionnaire`**: when the thing blocking you isn't in your head or the codebase but in **someone else's**, this writes them a questionnaire to fill in. It's the inverse of `/grill-me`: instead of interviewing you about the subject, it interviews you about the **send**, who it's going to, what you need back, and aims the questions at the gap. What comes back is material for `/grill-with-docs` or `/to-spec`.
- **`/wizard`**: for the steps only a **human** can take: provisioning infrastructure, setting up credentials or CI secrets, clicking through an unfamiliar third-party dashboard, running a one-off migration or cutover. It generates an interactive bash script that opens each URL, captures each value, and writes it into `.env` and GitHub secrets, so the procedure stops being something you re-explain to an agent every time. Model-invoked, so the agent reaches for it the moment it hits a wall only you can pass. If the agent could just do it itself, it should; this is for where a human is genuinely in the loop.
- **`/wait-what`**: the corrective for a message that didn't land. Use it mid-conversation, inside any other skill, and the agent re-pitches what it just said with the context you were missing, in plain English, using the `GLOSSARY.md` vocabulary. It works after the fact; `/grill-with-docs` is the upfront cure, because a shared language agreed early is what stops the jargon arriving at all.
- **`/writing-for-agents`**: reference for writing documents agents consume: skills, AGENTS.md, pointed-at docs.
- **`/review-mr`**: review someone else's merge request (GitLab, GitHub, or two local branches) for bugs, security, performance and design, check it against the task's acceptance criteria, and write a verdict (approve or request changes, and why) plus the findings to a local markdown file. It asks you what the diff can't answer before it judges. Where `/review-axes` judges your own diff against the repo's standards and spec, this judges someone else's.
- **`/delegate-tickets`**: orchestrate sequential ticket implementation through fresh subagents, one ticket at a time, each required to run `/implement`. Reach for it once `/to-tickets` has produced the tickets and you want the build to run unattended across all of them, `/clear`ing context between each. It only runs Standard and Light tickets (on Sonnet at medium effort); a Heavy ticket, or one with no `Difficulty:` line, stops the run so you take it by hand. It also stops, rather than pressing on, whenever a step needs a human answer.

## Precondition

- **`/setup-skills`**: run before your first engineering flow to configure the issue tracker, triage labels, doc layout, and project `.claude/settings.json` deny rules for destructive git. Custom issue trackers also work.
- **`/setup-solid`**: optional, once per repo. Writes a SOLID section into `CLAUDE.md` that binds every later flow: architecture-level, language-agnostic, and scoped by the **boy scout rule**, SOLID lands on new code and on the code a change already touches, so the codebase converges a change at a time. Where `/improve-codebase-architecture` finds a refactor to *do*, this sets the standard the code is *written* to.
