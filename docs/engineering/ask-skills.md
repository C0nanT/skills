Quickstart:

```bash
npx skills add C0nanT/skills --skill=ask-skills
```

```bash
npx skills update ask-skills
```

[Source](https://github.com/C0nanT/skills/tree/main/skills/engineering/ask-skills)

## What it does

`ask-skills` is the router over the skills in this repo. You describe the situation you're in; it tells you which skill or flow fits and in what order to run them.

It **does no work itself**. It doesn't grill, write a PRD, or fix anything — it only orients. It exists for the **user-invoked** skills above all: nothing fires those for you, so *you* have to remember they exist, and `ask-skills` is the memory you offload that to. It also points at the model-invoked skills you'd reach for by name — `/tdd`, `/diagnosing-bugs`, `/prototype`, `/review-axes`. It answers "which one, and when", then hands you off to the skill that actually does the job.

## When to reach for it

You invoke this by typing `/ask-skills` — the agent won't reach for it on its own.

Reach for it whenever you're unsure which skill or flow a situation calls for: you have an idea and don't know where to start, or two skills that look interchangeable and you can't tell them apart. If you already know the skill you want, skip the router and invoke it directly.

## Flows, not just skills

The idea `ask-skills` gives you to think with is the **flow** — a path *through* the skills rather than a single one. Most work runs along one **main flow** (idea → ship: grill → PRD → issues → implement → review), an **on-ramp** merges onto it (something's broken → diagnose → fix), and everything else is a **standalone** you reach for on its own. Ask a question and you get placed on the right flow, at the right step — not just handed a tool.

## Where it fits

`ask-skills` is the **router** — the standalone map that sits over the whole set. It never sits *in* a chain; it points *into* every chain. From here you'll most often land on [grill-with-docs](https://aihero.dev/skills-grill-with-docs), the head of the main flow. When even the router's own picture is stale, its [Source](https://github.com/C0nanT/skills/tree/main/skills/engineering/ask-skills) is the map of record.
