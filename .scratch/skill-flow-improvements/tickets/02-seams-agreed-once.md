# 02: Seams agreed once and carried to every ticket

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** seams are confirmed once, in `to-spec`, and never re-asked downstream. `to-spec` folds the seam confirmation into its single batch of questions (with the proposal as best guess; one short seams-only question when nothing else clears the bar) and writes the seams into Testing Decisions one per bullet. `to-tickets` copies the seams each ticket exercises into a `**Seams:**` line (local template) and the same content in the remote issue template, saying so explicitly when a ticket tests no seam. `tdd` treats seams from the ticket's `Seams:` line, else the spec's Testing Decisions, as already agreed and only asks about a seam not on the list; standalone with no source, it asks as today.

**Blocked by:** 01 (both edit the `to-tickets` ticket template)

**Status:** ready-for-human

- [x] `to-spec` has no separate "check with the user" seams step; seams are part of the one-batch question rule, including the seams-only short question case
- [x] `to-spec` template's Testing Decisions asks for the agreed seams, one per bullet
- [x] `to-tickets` local template has a `**Seams:**` line; remote issue template has an equivalent section; both say to state "none" explicitly
- [x] `tdd` defines the agreed-seam source order (ticket `Seams:` → spec Testing Decisions → none) and only asks for unlisted seams
- [x] `tdd` standalone behaviour (no ticket, no spec) unchanged
- [x] Fork divergence ledger: rows for `to-spec` (seams in the single batch), `to-tickets` (`Seams:` field) and `tdd` (agreed seams from ticket or spec), each with a grep phrase
- [x] Docs pages for `to-spec`, `to-tickets` and `tdd` re-synced for this behaviour
- [x] No em-dashes in touched prose; `scripts/validate.sh` passes
