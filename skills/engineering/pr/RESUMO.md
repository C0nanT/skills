# Resumo: pr

**O que faz:** dá o formato do corpo de um pull request: um **Summary** com a menor visualização que mostra a mudança (pseudocódigo, árvore de chamadas, árvore de componentes, árvore de arquivos, Mermaid ou diff), um **Evidence** com antes e depois (capturas de tela ou testes que passam a falhar e a passar) e um **Merge Danger** que classifica o PR como porta de mão única ou de mão dupla e descreve o raio de impacto. Foi adaptada da skill `show-me`, de Dex Horthy (Humanlayer), com os créditos no frontmatter.

**Quando usar:** sempre que o agente escrever o corpo de um PR.

**Como invocar:** o agente a chama sozinho ao escrever um PR (sem `disable-model-invocation`). Não há um comando `/pr` separado para o usuário.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `CREDITS.md` (créditos da origem, mantido em inglês) e este `RESUMO.md`.
