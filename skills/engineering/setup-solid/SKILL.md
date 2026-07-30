---
name: setup-solid
description: Write a SOLID section into this repo's CLAUDE.md — architecture-level, language-agnostic, applied by the boy scout rule so the codebase converges a change at a time instead of in one big refactor. Run once per repo.
disable-model-invocation: true
---

# Setup SOLID

Install one durable instruction into the repo: **apply SOLID at the architecture level, by the boy scout rule.**

The **boy scout rule** is the whole point of this setup. SOLID lands on code being written now and on the code the current flow already passes through — never on the repo at large. The codebase converges one change at a time.

The section is **language-agnostic**: it talks about modules, seams, and dependency direction, not about a framework's DI container or a language's `interface` keyword. What makes it worth writing is the exploration in step 1 — the section names *this* repo's real layers and paths.

## Process

### 1. Explore

Read the repo before drafting. Don't assume:

- Languages and how code is grouped — packages, folders, services. Which folders hold **policy** (domain / business rules) and which hold **details** (DB, HTTP, SDKs, filesystem)?
- `CLAUDE.md` and `AGENTS.md` at the root — does either exist? Is there already a `## SOLID` section, or an architecture/coding-standards section that overlaps it?
- `CONTEXT.md` — the domain vocabulary the section should use for this repo's concepts.
- ADRs (`.agents/adr/`, `docs/adr/`) — architecture decisions the section must not contradict.
- How dependencies already get injected (constructor args, function params, a container, module imports) and how tests already substitute them — the section should describe the convention that exists, not import a new one.
- Whether the docs are written in English or another language.

Done when you can name, in this repo's own paths, where policy lives, where details live, and how the two are currently wired.

### 2. Draft and confirm

Show the user the full section you intend to write, with the placeholders filled from step 1. Ask only what genuinely branches:

- Which file to write to, **only** when neither `CLAUDE.md` nor `AGENTS.md` exists.
- Anything exploration left ambiguous — e.g. two plausible policy folders.

Let them edit the draft before you write.

### 3. Write

Pick the file: edit `CLAUDE.md` if it exists; else `AGENTS.md`; else the one the user chose. Never create the other one when one is already there.

If a `## SOLID` section already exists, update it in place. Leave surrounding sections untouched.

Write the section in the language the rest of the file is written in.

The section:

```markdown
## SOLID

Apply SOLID at the **architecture** level — module boundaries, dependency direction, and the interfaces between them. It is a way to shape seams, not a naming ritual. "Module" means whatever this codebase groups behaviour into: a class, a package, a file of functions, a service.

### Scope — boy scout rule

SOLID applies to:

- code written new in the current change, and
- the existing code the current flow already passes through, when a small local edit clears friction that change is hitting.

The rest of the codebase stays as it is. Keep a change's blast radius on the flow being built or fixed — a repo-wide SOLID refactor is its own piece of work, and happens only when explicitly asked for. The codebase converges one change at a time.

When applying a principle would require reshaping modules outside the current flow, leave them alone and say so in the summary of the change.

### The principles, as architecture rules

- **SRP** — a module has one reason to change. When one flow forces edits in a module that other flows also own for unrelated reasons, that module is holding two responsibilities.
- **OCP** — new behaviour arrives as a new implementation behind an existing interface, rather than another branch in a growing conditional over kinds of thing.
- **LSP** — every implementation of an interface is substitutable through that interface: same contract, same error behaviour, no "this one also needs X called first".
- **ISP** — a consumer depends on the narrow interface it actually uses. Interfaces are shaped by the caller's need, not by everything the implementation can do.
- **DIP** — policy [POLICY LOCATION] does not depend on details [DETAILS LOCATION]. The interface belongs to the policy side; the detail implements it and is passed in [INJECTION CONVENTION].

### Applying it

- When a new flow crosses an IO boundary, define the interface from the policy side and inject the implementation.
- One implementation is enough — the seam pays off the moment a test substitutes it. Don't add abstraction layers with a single caller and no substitution.
- Use this repo's domain vocabulary (`CONTEXT.md`) when naming modules and interfaces.
```

Fill `[POLICY LOCATION]`, `[DETAILS LOCATION]`, and `[INJECTION CONVENTION]` with this repo's real paths and convention from step 1. Drop the `CONTEXT.md` line when the repo has no such file, and drop any bullet that contradicts a recorded ADR.

### 4. Done

Tell the user which file you edited, and that SOLID now applies to new code and to the code each change already touches — no separate refactor pass is coming. Re-running this skill is only needed to reshape the section itself; editing it directly is fine.
