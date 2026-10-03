# Tech debt review index

One row per module, maintained by the `tech-debt-map` skill. The partition below is a contract: later reviews are measured against these names and globs. Reports are working material under `.scratch/tech-debt-map/`; this index is what survives.

| Module | Paths | Origin | Last review | Report | Open |
| ------ | ----- | ------ | ----------- | ------ | ---- |
| Engineering skills | `skills/engineering/**` | declared | 2026-10-03 | `.scratch/tech-debt-map/engineering-skills/2026-10-03.md` | 0 |
| Docs | `docs/**` | proposed | never | | |
| In-progress skills | `skills/in-progress/**` | declared | never | | |
| Plugin and tooling | `scripts/**`, `.claude-plugin/**`, `.github/**`, `.changeset/**`, `*.sh` (repo root), `.agents/local-skills/**` | proposed | never | | |
| Productivity skills | `skills/productivity/**` | declared | never | | |
| Agent standards | `.agents/*.md`, `.agents/adr/**`, `CLAUDE.md`, `CONTEXT.md`, `AGENTS.md` | proposed | never | | |
| Misc skills | `skills/misc/**` | declared | never | | |
| Deprecated | `skills/deprecated/**` | declared | never | | |

Left out of every module: `node_modules/`, `.scratch/`, `.out-of-scope/`, `.vscode/`, `.cursor/`, `teste.md`.

## Findings ledger

Status of each finding across reviews, so the history survives a `.scratch/` wipe or a fresh clone.

### Engineering skills

| # | Finding | First seen | Status |
| - | ------- | ---------- | ------ |
| 1 | `setup-skills` deny-rule merge erases `.claude/settings.json` without `jq`; deny list misses `git -C` | 2026-10-03 | resolved (`ffbd903`) |
| 2 | Local tracker template lacks "Wayfinding operations"; `SPEC.md` vs `spec.md` | 2026-10-03 | resolved (`fa02423`) |
| 3 | Invocation mode disagrees across `SKILL.md`, `openai.yaml` and README (`tdd`, `research`, `implement`, missing `openai.yaml`) | 2026-10-03 | resolved (`9194a88`) |
| 4 | MR, issue and web text reach the shell and sub-agents with no data boundary | 2026-10-03 | resolved (`bb774bb`) |
| 5 | `delegate-tickets` spawns with no model or effort cap and no "no human, stop" rule | 2026-10-03 | resolved (`a6b2e71`) |
| 6 | Triage label contract: Section B gated on the excluded `triage` skill; `ready-for-human` definition mismatch | 2026-10-03 | resolved (`385858e`) |
| 7 | `ask-skills` routes with stale facts (`issues/`, "before committing", `/diagnosing-bugs`) | 2026-10-03 | resolved (`de7f506`) |
| 8 | `tech-debt-map` resolved-tracking lives only in `.scratch/` | 2026-10-03 | resolved (`8448954`) |
| 9 | `wizard` writes secrets to `.env` without checking `.gitignore` | 2026-10-03 | resolved (`1533a31`) |
| 10 | `delegate-tickets` pass gate relies on `review-axes` spec-search heuristic | 2026-10-03 | resolved (`a543559`) |

## Guardrails

Practices and checks that stop findings coming back. Appended to across reviews, never rewritten.

- `scripts/validate.sh` should check, for every skill: `disable-model-invocation: true` in `SKILL.md` if and only if `policy.allow_implicit_invocation: false` in `agents/openai.yaml`; that `agents/openai.yaml` exists; and that every `Call the Skill tool with "<name>"` target is model-invoked. (Engineering skills, 2026-10-03)
- Every invocation-mode change that differs from upstream gets a line in `.agents/fork-divergences.md` the same day. (Engineering skills, 2026-10-03)
- The ledger's revert-marker grep for the upstream ticket path should match any placeholder (`\.scratch/<[a-z-]*>/issues/`), not one spelling of it. (Engineering skills, 2026-10-03)
- Any skill that feeds third-party text (MR, issue, web page) into a shell command or a sub-agent brief states that the text is untrusted data and quotes refs. (Engineering skills, 2026-10-03)
- Any skill that runs unattended stops and reports when it hits a gate that needs a human answer; it never falls back to doing the work inline. (Engineering skills, 2026-10-03)
