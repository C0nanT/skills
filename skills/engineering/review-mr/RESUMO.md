# Resumo: review-mr

**O que faz:** revisa o merge request (ou PR) de **outra pessoa**, no GitLab, no GitHub ou entre dois branches locais, em quatro eixos: Correctness, Security (feitos nesta sessão) e Performance e Design (feitos por um único subagente barato). Confere o código contra os critérios de aceitação extraídos da descrição do MR, pergunta antes de julgar o que o diff não consegue explicar e aplica uma regra de corte: só entra no relatório o que tem um caminho concreto de execução. Escreve tudo em `.scratch/reviews/<slug>.md`, com um veredito no topo: Request changes, Approve with comments, Approve ou Blocked on answers. Em novas rodadas, acrescenta uma seção e reconcilia os achados anteriores.

**Quando usar:** quando você precisa revisar o código de um colega antes de mesclar. Para revisar o *seu* próprio diff contra padrões e especificação, use `/review-axes`.

**Como invocar:** `/review-mr`, com o número, a URL ou os dois branches. É uma skill só para o usuário (`disable-model-invocation: true`). Ela nunca publica comentários sozinha: só depois da sua aprovação, comentário por comentário.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
