# `/scaffold-exercises` — Create Exercise Structure

## What it is

A skill specifically for creating course exercise directory structures that pass the `pnpm ai-hero-cli internal lint` linter.

## What it's for

- Creating the structure for a new exercise in a course
- Adding a new section with multiple exercises
- Batch scaffolding from a content plan

**Note**: This is a skill specific to projects using `ai-hero-cli`. It's unlikely to be useful outside that context.

## How to invoke

```
/scaffold-exercises
```

Describe what you want to create (section, exercises, variants).

## How it works

### Naming structure

- **Sections**: `XX-section-name/` inside `exercises/` (e.g. `01-retrieval-skill-building`)
- **Exercises**: `XX.YY-exercise-name/` inside a section (e.g. `01.03-retrieval-with-bm25`)
- Names in dash-case (lowercase, hyphens)

### Variants per exercise

Each exercise has at least one of:
- `problem/` — student workspace with TODOs
- `solution/` — reference implementation
- `explainer/` — conceptual material, no TODOs

Default when stubbing: `explainer/` unless the plan specifies otherwise.

### Required files

Each subfolder needs a `readme.md` that:
- Is not empty
- Has no broken links

Minimal stub:
```md
# Exercise Title

Description here
```

If the subfolder has code, it needs a `main.ts` (>1 line).

### Process

1. Parse the plan — extract section names, exercises, variant types
2. Create directories with `mkdir -p`
3. Create stub readmes with title
4. Run `pnpm ai-hero-cli internal lint` to validate
5. Fix errors and iterate until lint passes
6. Commit

### Linter rules

The linter checks:
- Exercise has subfolders (`problem/`, `solution/`, `explainer/`)
- At least one of `problem/`, `explainer/`, or `explainer.1/` exists
- `readme.md` exists and is not empty in the main subfolder
- No `.gitkeep` files
- No `speaker-notes.md` files
- No broken links in readmes
- `main.ts` required per subfolder (unless it's readme-only)

### Moving or renumbering exercises

Use `git mv` (not `mv`) to preserve git history. Update the numeric prefix to maintain order. Re-run lint after moving.

## Usage example

```
I want to create section 05: Memory Skill Building, with 3 exercises:
- 05.01 Introduction to Memory (explainer)
- 05.02 Short-term Memory (explainer + problem + solution)
- 05.03 Long-term Memory (explainer)

/scaffold-exercises
```

The agent will create the directories, create stub readmes, run lint, and commit.
