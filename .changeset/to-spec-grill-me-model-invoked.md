---
"mattpocock-skills": patch
---

Make `to-spec` and `grill-me` model-invoked: drop `disable-model-invocation` and the `policy.allow_implicit_invocation: false` block in `agents/openai.yaml`, give both a model-facing description with trigger phrasing, and move them to the Model-invoked groups in the READMEs. The docs pages now say the agent can also reach for them on its own.
