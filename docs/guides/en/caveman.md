# `/caveman` — Ultra-Compressed Communication Mode

## What it is

A productivity skill that activates ultra-compressed communication mode. The agent talks like a "smart caveman" — keeps all technical substance, but drops articles, filler, pleasantries, and hedging. Reduces token usage by ~75%.

## What it's for

- When you want faster, more direct answers
- To save tokens in long sessions
- When you're already experienced on the topic and don't need lengthy explanations
- Any time verbosity is getting in the way of productivity

## How to invoke

```
/caveman
```

Or just say: "caveman mode", "less tokens", "be brief", "talk like caveman".

To deactivate:
```
stop caveman
normal mode
```

## How it works

Once activated, the agent:

**Drops:**
- Articles (a, an, the)
- Filler (just, really, basically, actually, simply)
- Pleasantries (sure, certainly, of course, happy to)
- Hedging (might, perhaps, potentially)
- Unnecessary conjunctions

**Keeps:**
- All exact technical terms
- Code blocks unchanged
- Errors quoted exactly

**Uses:**
- Sentence fragments when sufficient
- Short synonyms (big not "extensive", fix not "implement a solution for")
- Common abbreviations (DB, auth, config, req, res, fn, impl)
- Arrows for causality (X → Y)
- One word when one word is enough

**Pattern:** `[thing] [action] [reason]. [next step].`

### Examples

**Normal mode:**
> "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by a problem in the authentication middleware where the token expiry check is using the wrong comparison operator..."

**Caveman mode:**
> "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

### Auto-clarity exception

Caveman mode is temporarily suspended for:
- Security warnings
- Irreversible action confirmations
- Multi-step sequences where fragments could cause misreading
- When the user asks to clarify or repeats a question

After the critical part, caveman mode resumes automatically.

## Persistence

Once activated, persists **across all responses** in the session. Does not revert over time. Only deactivates when you explicitly say "stop caveman" or "normal mode".

## Tip

Useful to combine with long `/tdd` or `/diagnose` sessions where you want fast technical answers without extra prose.
