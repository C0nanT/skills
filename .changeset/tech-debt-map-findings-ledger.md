---
"mattpocock-skills": minor
---

tech-debt-map: the review index now carries a per-module Findings ledger (finding, first seen, status, resolving commit), so finding history survives a `.scratch/` wipe and a fresh clone. When the previous report is missing, the next review reads the ledger to mark fixed findings resolved, and every review updates it at the end. Reports stay in `.scratch/`.
