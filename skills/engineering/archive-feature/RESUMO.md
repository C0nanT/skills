# Resumo: archive-feature

**O que faz:** arquiva funcionalidades terminadas. Verifica se a especificação e os tickets em `.scratch/<feature-slug>/` estão prontos (status `ready-for-human` ou `done` e todos os checkboxes marcados), ajusta as linhas `Status:` e move a pasta inteira para `docs/archive/` com `git mv`. Pode arquivar uma funcionalidade indicada ou todas de uma vez, com uma tabela de prontidão e uma confirmação. Não marca checkboxes e nunca sobrescreve um destino existente. Só funciona com o tracker local em markdown.

**Quando usar:** quando uma funcionalidade foi concluída e você quer tirá-la de `.scratch/` antes da limpeza periódica, mantendo-a no repositório.

**Como invocar:** `/archive-feature`, com o nome de uma funcionalidade ou sem argumento. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
