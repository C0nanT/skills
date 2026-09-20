---
"mattpocock-skills": minor
---

tech-debt-map: audit one module per run instead of the whole project. The skill now works out how the project divides into modules (proposing a partition where the build system declares none), asks which one to review, and shows how long since each was last looked at. It keeps a committed review index at `docs/tech-debt/README.md` holding the partition, the last-review dates and the project-wide guardrails, and writes one report per review under `.scratch/tech-debt-map/<module>/<date>.md`. The `Effort` rating is replaced by `Blast radius` (Contained / Module+ / Systemic), which is read off the code rather than estimated, the cap drops to 10 findings, `needs-validation` findings are now put to the user in one batched round before the file is written, and the handoff goes through `/to-spec` before `/to-tickets`.
