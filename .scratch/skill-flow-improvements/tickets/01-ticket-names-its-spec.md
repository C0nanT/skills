# 01: Ticket names its spec, review finds it without guessing

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** a local ticket written by `to-tickets` carries a `**Spec:**` line with its spec's path relative to the ticket file. `review-axes` finds the spec in the new order (argument → ticket's `Spec:` line → remote `Parent` → current heuristic → ask), and `implement` hands it the ticket or spec path explicitly in its Review step, so inside the pipeline the Spec axis never depends on search. Checkbox sync keeps targeting the ticket file when a ticket was passed. Closes tech-debt finding #10.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `to-tickets` local ticket template has a `**Spec:**` line, explained as the spec path relative to the ticket file
- [ ] `review-axes` spec search lists the new five-step order, with the ticket's `Spec:` line second
- [ ] `review-axes` step 6 states that checkbox sync targets the ticket file, not the spec it points to, when a ticket was passed
- [ ] `implement` Review step passes the ticket path (or spec path with no ticket) alongside "the unstaged working tree"
- [ ] `delegate-tickets` re-read; its instruction about invoking `review-axes` is consistent with `implement` passing the ticket path (edited only if it contradicts)
- [ ] Fork divergence ledger: `to-tickets` row for the `Spec:` field added; existing `review-axes` "local-markdown first" row updated to the new order, each with a grep phrase
- [ ] Docs pages for `to-tickets`, `review-axes` and `implement` re-synced for this behaviour
- [ ] Tech-debt ledger finding #10 marked resolved
- [ ] No em-dashes in touched prose; `scripts/validate.sh` passes
