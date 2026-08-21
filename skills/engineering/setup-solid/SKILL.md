---
name: setup-solid
description: Write an architecture-level SOLID section into this repo's CLAUDE.md, scoped by the boy scout rule. Run once per repo.
disable-model-invocation: true
---

# Setup SOLID

Install one durable instruction into the repo: **apply SOLID at the architecture level, by the boy scout rule.**

The **boy scout rule** is the whole point of this setup. SOLID lands on code being written now and on the code the current flow already passes through, never on the repo at large. The codebase converges one change at a time.

The section is **language-agnostic**: it talks about modules, seams, and dependency direction, not about a framework's DI container or a language's `interface` keyword. What makes it worth writing is the exploration in step 1, the section names *this* repo's real layers and paths.

The section is always written in **English**, like the rest of the code standards, whatever language the repo's prose is in.

## Process

### 1. Explore

Read the repo before drafting. Don't assume:

- Languages and how code is grouped: packages, folders, services. Which folders hold **policy** (domain / business rules) and which hold **details** (DB, HTTP, SDKs, filesystem)?
- `CLAUDE.md` and `AGENTS.md` at the root: does either exist? Is one a symlink to the other? Is there already a SOLID section (at any heading level or casing), or an architecture / coding-standards section that overlaps it?
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, a populated `packages/*` with per-package `CLAUDE.md` files. Only relevant if the packages have *genuinely different* layer layouts; otherwise the root file covers them.
- `CONTEXT.md`: the domain vocabulary the section should use for this repo's concepts.
- ADRs (`.agents/adr/`, `docs/adr/`): architecture decisions the section must not contradict.
- How dependencies already get injected (constructor args, function params, a container, module imports) and how tests already substitute them: the section should describe the convention that exists, not import a new one.

Done when you can name, in this repo's own paths, where policy lives, where details live, how the two are currently wired, and how a test substitutes a detail.

**When there's no policy/details split, stop.** A docs repo, a thin scripts repo, a repo of prompt files: nothing there has an IO boundary to shape. Tell the user the repo has no layers for this section to name, and don't write it. If the split exists but is thin (one small domain folder, no interfaces yet), offer the reduced section: SRP and OCP only, no `### In this repo` block, and say what you dropped.

### 2. Draft and confirm

Show the user the full section you intend to write, with the placeholders filled from step 1. Ask only what genuinely branches:

- Which file to write to, **only** when neither `CLAUDE.md` nor `AGENTS.md` exists.
- Anything exploration left ambiguous: e.g. two plausible policy folders.

Surface, rather than silently resolving:

- **An overlapping standards section.** If an architecture or coding-standards section already rules on dependency direction or abstraction, say so and propose either folding SOLID into it or having SOLID defer to it. Two sets of rules on the same question in one file is worse than none: `/review-axes` reads them both as documented standards.
- **An ADR conflict.** If an ADR contradicts a principle, name the ADR and the bullet. Don't drop the principle silently; a missing DIP bullet is an unexplained hole.

Let them edit the draft before you write.

### 3. Write

Pick the file: edit `CLAUDE.md` if it exists; else `AGENTS.md`; else the one the user chose. Never create the other one when one is already there, and when one is a symlink to the other, writing through either is writing both, so pick one and don't touch the second path.

If a SOLID section already exists: at any heading level or casing: update it in place rather than appending a second one. Leave surrounding sections untouched.

The section:

```markdown
## SOLID

Apply SOLID at the **architecture** level: module boundaries, dependency direction, and the interfaces between them. It is a way to shape seams, not a naming ritual. "Module" means whatever this codebase groups behaviour into: a class, a package, a file of functions, a service.

### Scope: boy scout rule

SOLID applies to:

- code written new in the current change, and
- the existing code the current flow already passes through, when a small local edit clears friction that change is hitting.

The rest of the codebase stays as it is. Keep a change's blast radius on the flow being built or fixed: a repo-wide SOLID refactor is its own piece of work, and happens only when explicitly asked for. The codebase converges one change at a time.

When applying a principle would require reshaping modules outside the current flow, leave them alone and say so in the summary of the change.

### In this repo

- **Policy**: [POLICY PATHS]
- **Details**: [DETAILS PATHS]
- **Wiring**: [INJECTION CONVENTION]
- **Test substitution**: [TEST SUBSTITUTION CONVENTION]

### The principles, as architecture rules

- **SRP**: a module has one reason to change. When one flow forces edits in a module that other flows also own for unrelated reasons, that module is holding two responsibilities.
- **OCP**: new behaviour arrives as a new implementation behind an existing interface, rather than another branch in a growing conditional over kinds of thing.
- **LSP**: every implementation of an interface is substitutable through that interface: same contract, same error behaviour, no "this one also needs X called first".
- **ISP**: a consumer depends on the narrow interface it actually uses. Interfaces are shaped by the caller's need, not by everything the implementation can do.
- **DIP**: policy does not depend on details (see *In this repo* above for both). The interface belongs to the policy side; the detail implements it and is passed in.

### Applying it

- When a new flow crosses an IO boundary, define the interface from the policy side and inject the implementation.
- One production implementation is enough **when a test substitutes it**: the test double is the second implementation, and the interface is the test surface. An adapter behind an interface with a single caller and no substitution is a hypothetical seam: drop the interface until something real needs it.
- Use this repo's domain vocabulary (`CONTEXT.md`) when naming modules and interfaces.
```

Fill `[POLICY PATHS]`, `[DETAILS PATHS]`, `[INJECTION CONVENTION]`, and `[TEST SUBSTITUTION CONVENTION]` with this repo's real paths and conventions from step 1: concrete globs (`src/domain/**`), not categories. Drop the `CONTEXT.md` line when the repo has no such file. Where an ADR overrides a principle, keep the bullet and add the exception inline, citing the ADR.

Then re-read what you wrote and check: no `[PLACEHOLDER]` survived, and there's exactly one SOLID section in the file. A leftover placeholder becomes permanent noise for every skill that reads this file afterwards.

### 4. Done

Tell the user:

- Which file you edited.
- That SOLID now applies to new code and to the code each change already touches: no separate refactor pass is coming.
- **That this changed how other skills behave.** `/review-axes` treats a documented repo standard as winning over its own baseline, so from now on it flags diffs that break these bullets, citing this section; `/implement` reads them while writing code. If that's stricter than they want, now is the moment to soften a bullet.

Re-running this skill is only needed to reshape the section itself; editing it directly is fine.
