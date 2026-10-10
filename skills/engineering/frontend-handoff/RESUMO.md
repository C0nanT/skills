# Resumo: frontend-handoff

**O que faz:** lê uma mudança de backend já concluída (especificação, tickets, branch, PR ou diff) e produz um handoff para a equipe de frontend, começando por um **veredito** (deve mudar, deveria mudar ou nada é necessário). Depois traz a tabela de contrato da API (rotas, envelope, enums, códigos HTTP), o impacto por área do frontend, exemplos de payload, o que o frontend deve parar de assumir e uma checklist. Salva o resultado em `.scratch/<feature-slug>/frontend-handoff.md`, a menos que o veredito seja "nada é necessário".

**Quando usar:** depois do `/implement`, quando uma mudança de backend é entregue e outra equipe precisa saber se tem de alterar algo.

**Como invocar:** `/frontend-handoff`, com a mudança como argumento. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
