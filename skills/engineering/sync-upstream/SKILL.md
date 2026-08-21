---
name: sync-upstream
description: Merge an upstream repo into this fork and resolve the conflicts in favour of the fork's deliberate divergences, then sweep for the ones the merge overwrote silently.
disable-model-invocation: true
---

A fork diverges from its upstream on purpose: renamed things, changed behaviour, dropped files. A merge doesn't know that. It resolves what it can and hands you the rest, and the danger isn't the conflicts it shows you: it's the files it merged **cleanly** by taking upstream's text back over a divergence you meant to keep.

So this skill has two halves, and the second is the one that earns it: resolve the marked conflicts, then hunt the silent ones.

## 1. Read the ledger first

The fork's divergences live in a **ledger**: a file listing each way this repo deliberately differs from upstream. Look for it at `.agents/fork-divergences.md`, then anywhere `CLAUDE.md` / `AGENTS.md` points. Read it before touching a single conflict; it is the primary source for every resolution below.

No ledger? Say so, work from what the diff and `CLAUDE.md` tell you, and **write one at the end**: the sweep in step 4 is worthless without it, and the next sync starts blind again.

## 2. Merge

If a merge is already in progress (`git status` shows unmerged paths), skip to step 3: the human ran it themselves.

Otherwise: prefer the repo's own sync script if one exists (`scripts/sync-upstream.sh` or similar in `package.json`), it knows which upstream paths this fork strips. Failing that, `git fetch upstream && git merge upstream/main --no-commit --no-ff`.

Record the merge base: `git merge-base HEAD upstream/main`: you need it in step 3.

## 3. Resolve each conflicted file

`git diff --name-only --diff-filter=U`. For each file, the question is never "ours or theirs". It is **what did upstream actually change, and does it collide with a ledger entry?** Find out:

```bash
git diff <merge-base> upstream/main -- <path>   # upstream's real delta, without the fork's noise
```

Then resolve by kind:

| What upstream's delta is | Resolve to |
| --- | --- |
| Cosmetic: reworded, re-italicised, renamed to upstream's name for something this fork renamed | The fork's side. Nothing was added. |
| New substance: a section, a rule, a step the fork doesn't have | Upstream's side, **rewritten into the fork's names and facts** |
| Both: new substance sitting on top of a rename | Take upstream's text, re-apply every ledger entry to it |
| A behaviour the fork deliberately changed or added | The fork's side, always. Never let an upstream rewrite quietly delete a fork feature. |

Two rules bind the whole step:

- **Never `git checkout --ours <file>` on a conflicted file.** It throws away the parts of upstream's delta that merged cleanly in the same file, and it does it invisibly.
- **A doc that describes fork behaviour must be re-checked against the fork's `SKILL.md`, not just renamed.** Upstream's prose is written about upstream's behaviour: a FAQ answering "no, it can't do X" is *wrong* in a fork where X works. Renaming it leaves a confident lie in place.

## 4. Sweep for silent clobbers

The important half. A file with no conflict markers can still have lost a divergence, because git merged upstream's line in without asking.

For every rename in the ledger, count the upstream-side name before and after the merge:

```bash
git grep -c "<upstream-name>" HEAD -- docs skills     # what the fork had
grep -rc "<upstream-name>" docs skills | grep -v ":0" # what the merge left
```

Any file whose count **went up**, or that appears only in the second list, took upstream's name back. Fix it. Do the same for each behavioural divergence, using a phrase unique to upstream's version of it.

Then check what moved rather than changed: `git status` for files upstream renamed, moved between buckets, or deleted, a promoted skill that upstream renamed leaves this fork's manifests pointing at a path that no longer exists.

## 5. Check the repo's own invariants

The merge can leave the repo internally inconsistent without a single conflict. Read `CLAUDE.md` for the invariants this repo declares, and verify each one that the merge could have touched. Typically:

- Manifests that must list every promoted skill, and must not list the others.
- `README.md` and per-bucket `README.md`s that must carry an entry each.
- Any router or index skill that maps the set: a skill it never mentions, or a stale one it still routes to, is a router that lies.
- Whatever validation command the repo documents (`claude plugin validate . --strict`, a lint, a link check). Run it.

Upstream skills newly promoted into a shipped bucket are a **decision, not a fix**: list them for the human and ask whether the fork wants them, rather than adding them silently.

## 6. Update the ledger, then report

Every divergence you had to defend, and every new one you discovered, goes into the ledger: that is what makes the next sync cheaper than this one. Add anything upstream now does that made a ledger entry obsolete, too, and delete the entry.

Report, grouped: conflicts resolved and which way each went; silent clobbers caught and fixed; invariants checked and what failed; decisions left to the human. **Do not commit.** The merge stays open for the human to review unless they ask you to finish it.
