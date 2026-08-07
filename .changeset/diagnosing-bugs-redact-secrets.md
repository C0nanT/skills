---
"mattpocock-skills": patch
---

Make `diagnosing-bugs` redact secrets.

- Add a **Redact** section to `SKILL.md`. The skill has the agent show commands, outputs and captured artifacts; the section makes redaction the first move on each — write `<REDACTED>`, build loops against env vars so the credential stays in the environment, and quote only the signal-carrying lines of a captured artifact.
- The Phase 1 completion criterion said "paste the invocation and its output". It now says show it redacted, and Phase 1 asks the user for a **redacted** captured artifact.
- Note in `scripts/hitl-loop.template.sh` that `capture` prints its value back to the terminal, so it takes observations while signing in stays a `step`.
