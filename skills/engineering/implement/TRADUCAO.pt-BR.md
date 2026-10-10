```yaml
name: implement
description: "Implemente um trabalho com base em uma especificação ou conjunto de tickets. Use quando o usuário quiser que uma especificação, ticket ou plano acordado pronto seja construído, ou quando disser para implementar."
```

Implemente o trabalho descrito pelo usuário na especificação ou nos tickets, em seis passos. Cada passo só está concluído quando o seu critério de conclusão é atendido.

Se o usuário passar a referência de um ticket, busque-o no issue tracker e informe o título antes de começar. Se a referência for ambígua, pergunte.

## Esforço dos subagentes

Todo subagente criado durante esta execução, seja por você, seja por uma skill que você invoque (`/tdd`, `/review-axes`), roda com **`effort: medium`**, qualquer que seja o modelo. O nível de esforço do usuário pertence apenas a esta sessão e nunca é transferido para um subagente.

`high` ou acima (`high`, `xhigh`, `max`) exige o sim explícito do usuário **antes** da criação: pergunte, nomeie o subagente, o modelo, o esforço e por que o medium não basta, e então espere. Sem resposta, é não. Um sim cobre apenas a criação para a qual foi pedido.

Quando o host não puder definir o esforço por subagente e o subagente herdaria um nível `high` ou superior desta sessão, essa herança conta como criação em `high`: exige o mesmo sim antes.

Se nenhum humano puder responder (você roda como subagente, sem supervisão, ou o briefing diz que ninguém está por perto), pare e reporte a pergunta como um bloqueio. Nunca volte a fazer o trabalho na mesma sessão. Em uma sessão interativa, continue perguntando e esperando o sim, como descrito acima. A mesma regra vale para qualquer outra pergunta que esta execução faria ao usuário, como onde está a especificação: sem supervisão, isso é um bloqueio, nunca um palpite.

## 1. Construir

Chame a ferramenta Skill com "tdd" sempre que possível, trabalhando nos seams acordados previamente. Rode a checagem de tipos com frequência e rode arquivos de teste individuais com frequência.

Tudo que você escrever e que sobreviva à execução (docblocks, comentários de código, READMEs, documentação, ADRs) nunca aponta para dentro de `.scratch/`: essa pasta é apagada periodicamente, então a referência ficaria pendurada. Declare o fato necessário diretamente no texto ou cite um arquivo permanente do repositório.

Pronto quando: cada parte da especificação ou dos tickets estiver escrita.

## 2. Testar

Rode a suíte de testes completa uma vez.

Pronto quando: a suíte tiver rodado e você souber o resultado.

## 3. Refatorar

Uma passada de limpeza no código que esta execução escreveu, somente enquanto a suíte estiver verde.

- **Pré-condição:** a suíte completa estava verde após o passo Testar. Se não estava, pule este passo e diga isso no Veredito.
- **Escopo:** apenas o código que o diff da execução criou ou alterou (a árvore de trabalho não commitada; portanto, sob `/delegate-tickets`, exatamente o ticket atual). Uma refatoração valiosa que você note fora do diff nunca é aplicada: anote-a para o Veredito.
- **Regra:** nenhuma mudança de comportamento. Nunca edite um teste para fazer uma refatoração passar.
- **Snapshot primeiro.** Use `git stash create` (registra o estado sem alterar nenhuma referência, índice ou árvore de trabalho) ou copie para o lado os arquivos do diff.
- **Depois de refatorar, rode a suíte completa.** Verde: mantenha a refatoração. Vermelho: restaure o snapshot para que a árvore de trabalho fique exatamente no estado verde anterior à refatoração (para um snapshot de `git stash create`, `git restore --source=<snapshot> --worktree -- <arquivos>`, que deixa o índice intocado; apague também qualquer arquivo que a refatoração criou e recrie qualquer um que ela tenha apagado, pois um snapshot não cobre esses casos), e então siga para a Revisão.

Pronto quando: a refatoração foi mantida com a suíte verde, ou desfeita até o snapshot verde, ou pulada porque a suíte estava vermelha.

## 4. Revisar

Invoque a skill /review-axes agora, como uma chamada real de Skill. Dê a ela **a árvore de trabalho não staged** como ponto fixo: as mudanças ainda não estão em nenhum commit, então um diff baseado em referência voltaria vazio. Junto, passe o caminho do ticket que você recebeu, ou o caminho da especificação quando não houver ticket, como argumento de spec, para que ela nunca precise procurar a especificação e sincronize os checkboxes certos. Deixe os checkboxes dos critérios de aceitação (`- [ ]` / `- [x]`) na especificação ou nos tickets para o `/review-axes`, que os sincroniza após a revisão de Spec com base no que o código realmente fez.

Pronto quando: `/review-axes` tiver devolvido seus relatórios de Standards e de Spec nesta execução. Os passos 1 a 3 concluídos são a entrada desta etapa, nunca um substituto para ela: o Veredito abaixo é construído a partir da saída da revisão, então ele não pode ser escrito antes de a revisão existir.

## 5. Commitar

Faça commit do seu trabalho no branch atual.

Pronto quando: as mudanças da execução estiverem em um commit no branch atual.

## 6. Reportar

Termine com uma seção **Veredito**.

### Veredito

Uma linha: o emoji, seguido de um motivo curto. 🟢 é o emoji **sozinho**, sem texto depois dele.

- 🟢 Tudo correu como planejado: totalmente implementado, nada se desviou da especificação ou dos tickets, `/review-axes` não levantou nada que exija ação, nenhuma ação do usuário é necessária. Imprima o emoji e nada mais.
- 🟡 Implementado, mas algo precisou ser ajustado no meio do caminho: a lógica planejada mudou, uma abordagem foi trocada, um detalhe da especificação foi interpretado, ou `/review-axes` levantou achados que merecem atenção. Também é 🟡: a refatoração foi desfeita porque a suíte ficou vermelha depois dela (motivo em uma linha), ou uma refatoração valiosa foi vista fora do diff (sugira um ticket de pré-fatoração, nunca aplique). Uma refatoração que foi mantida não afeta a cor. Uma refatoração pulada porque a suíte estava vermelha é declarada no Veredito, e a suíte vermelha em si define a cor como faz hoje. Diga o que mudou e por quê.
- 🔴 Algo não foi concluído, ou o usuário precisa agir antes de seguir: uma parte não foi implementada, `/review-axes` encontrou uma lacuna na especificação, uma decisão precisa da avaliação dele, uma etapa de credencial, migração ou manual é necessária, ou qualquer coisa que quebre o fluxo "apenas comece o próximo ticket". Diga o que é e o que ele precisa fazer.

Escolha a pior cor aplicável: qualquer condição vermelha torna o veredito 🔴, mesmo que o resto tenha corrido bem.
