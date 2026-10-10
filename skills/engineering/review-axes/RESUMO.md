# Resumo: review-axes

**O que faz:** revisa o diff entre o `HEAD` e um ponto fixo (commit, branch, tag, merge-base ou a árvore de trabalho não commitada) em dois eixos independentes. **Standards** verifica os padrões de código documentados do repositório, além de duas linhas de base fixas: smells (Fowler) e performance (N+1 e trabalho repetido). **Spec** verifica se o código cumpre o ticket ou a especificação de origem. Os dois rodam como subagentes paralelos e são reportados separadamente, sem reordenação. Ao final, sincroniza os checkboxes dos critérios de aceitação com o que o código fez e avança o `Status:` para `ready-for-human` quando tudo estiver marcado.

**Quando usar:** para revisar um branch, um PR ou mudanças em andamento, ou quando você pedir "review since X". É a revisão do **seu** trabalho. Para revisar o merge request de outra pessoa, use `review-mr`.

**Como invocar:** `/review-axes`, com um ponto fixo e, opcionalmente, o caminho do ticket. Pode ser chamada pelo agente (sem `disable-model-invocation`), por exemplo pelo `/implement`.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
