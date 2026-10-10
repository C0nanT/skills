```yaml
name: implement-spec
description: "Implemente em código o resultado de /to-spec e /to-tickets."
disable-model-invocation: true
```

Você recebeu uma especificação. Ela deve ter tickets associados, que descrevem como implementá-la.

Resolva o issue tracker da mesma forma que o `/to-tickets`: uma instrução explícita do usuário, senão `docs/agents/issue-tracker.md` (escrito pelo `/setup-skills`), senão markdown local em `.scratch/<feature-slug>/tickets/`.

O objetivo é a especificação inteira implementada em um único **branch de integração**, com cada ticket resolvido da forma como o issue tracker encerra o trabalho.

Os tickets não são uma lista de passos. Eles formam um **grafo de tarefas** com relações de bloqueio entre si. Isso significa que sempre há uma **fronteira** de tickets prontos para serem pegos.

A comunicação com subagentes deve ser esparsa. Comunique-se principalmente por **ponteiros de contexto**: a especificação, os tickets, as notas de pesquisa e os commits anteriores. Não duplique informações que já estão disponíveis por meio desses ponteiros.

Os **subagentes implementadores** devem rodar em segundo plano sempre que possível, para máxima concorrência.

## Passos

1. Leia a especificação e os tickets para entender o grafo de tarefas.

2. (opcional) Use um **subagente de exploração** para fazer qualquer exploração exigida pelos tickets: arquivos relevantes da base de código ou documentação externa. Garanta que o subagente de exploração consiga salvar arquivos: ele deve gravar as notas em markdown em um diretório fora do repositório, acessível a todos os subagentes futuros. Assim, os **subagentes implementadores** se concentram na implementação, e não na exploração.

3. Crie o branch de integração. Se o issue tracker encerra o trabalho por meio de PRs, ou se o usuário pedir, abra um PR em rascunho depois do primeiro merge do passo 5 (um branch sem commits à frente da main não pode abrir um PR), marcado como fechando a especificação e os tickets.

4. Use **subagentes implementadores** para implementar cada ticket, cada um em seu próprio worktree e em seu próprio branch. Cada subagente implementador:
   - confirma que seu worktree está baseado no branch de integração antes de começar, e faz reset para ele se não estiver;
   - chama a ferramenta Skill com `tdd` para construir o ticket;
   - faz merge da ponta do branch de integração no próprio branch antes de reportar que terminou

5. Assim que um **subagente implementador** terminar, faça merge do trabalho dele no branch de integração com um **subagente de merge**.

6. Se isso alterar a **fronteira** de tickets disponíveis, dispare mais **subagentes implementadores** para trabalhar nos novos tickets. Isso permite máxima concorrência.

7. Quando todos os tickets estiverem concluídos, chame a ferramenta Skill com `review-axes` no branch de integração, passando o caminho da especificação como argumento de spec. Corrija todos os problemas levantados pela revisão em um único **subagente implementador**.

8. Se existir um PR em rascunho, marque-o como pronto para revisão. Caso contrário, resolva cada ticket da forma como o issue tracker encerra o trabalho e informe o branch de integração.
   Em um tracker local em markdown, resolver um ticket significa marcar o arquivo dele no checkout principal (não em um worktree): troque cada critério de aceitação que o branch de integração implementa para `- [x]`, com base no relatório de Spec do passo 7 e no trabalho mesclado do ticket, deixe os não atendidos como `- [ ]` e defina `Status: ready-for-human` quando todas as caixas estiverem marcadas. Um ticket com alguma caixa desmarcada mantém o status e é listado no relatório. É isso que o `/archive-feature` verifica antes de arquivar a funcionalidade.

9. Limpe todos os worktrees dos **subagentes implementadores**.
