```yaml
name: to-spec
description: "Transforme a conversa atual em uma especificação e publique-a no issue tracker do projeto: síntese do que já foi discutido, perguntando apenas sobre as lacunas que você realmente não consegue preencher."
```

Esta skill pega o contexto da conversa atual e o entendimento da base de código e produz uma especificação. Por padrão, sintetize o que você já sabe: quando esta skill roda, as decisões normalmente já foram tomadas, então não as reabra como uma entrevista.

**Você pode fazer perguntas quando realmente precisar.** O critério é uma lacuna que você não consegue fechar a partir da conversa, da base de código, do `GLOSSARY.md` ou dos ADRs, e que de outro modo o obrigaria a inventar uma decisão que o usuário nunca tomou. Quando chegar nesse ponto:

- Pergunte em um único lote, antes de escrever a especificação, e não uma pergunta por vez.
- Limite-se às poucas que de fato mudam o que a especificação diz.
- Leve a sua melhor suposição junto de cada uma, para que o usuário possa responder apenas confirmando.
- Os seams (passo 3) são uma dessas perguntas: coloque os seams propostos no lote como sua melhor suposição. Se nada mais alcançar o critério, faça uma única pergunta curta, só sobre os seams.
- Depois escreva a especificação. Nunca fique parado esperando respostas que você poderia ter assumido e sinalizado.

Se nada alcançar esse critério, escreva a especificação sem perguntar nada, exceto os seams: esses são sempre confirmados, no lote ou na única pergunta curta sobre seams.

## Processo

1. **Resolva onde publicar.** Esta decisão nunca precisa de pergunta: a cadeia abaixo sempre chega a algum destino, então escolha o destino em silêncio e leve-o ao passo 4, em vez de apresentar um seletor.

   1. Se o usuário pediu explicitamente, nesta execução, para publicar no GitHub, GitLab, markdown local ou outro tracker: use esse.
   2. Senão, se `docs/agents/issue-tracker.md` existir (escrito pelo `/setup-skills`) e indicar um tracker: use esse.
   3. Senão: **markdown local** (`.scratch/<feature-slug>/SPEC.md`). Não consulte `git remote`. Não apresente um seletor de destino.

   Para GitHub ou GitLab, siga as convenções e os mapeamentos de rótulos de triagem de `docs/agents/issue-tracker.md`, quando ele existir; caso contrário, use o `<destination-conventions>` abaixo. Rode `/setup-skills` para configurar essas convenções e um vocabulário de rótulos de triagem.

2. Explore o repositório para entender o estado atual da base de código, se ainda não o tiver feito. Use o vocabulário do glossário de domínio do projeto em toda a especificação, e respeite os ADRs da área que você está tocando.

3. Esboce os seams nos quais você vai testar a funcionalidade. Seams existentes são preferíveis a novos. Use o seam mais alto possível. Se novos seams forem necessários, proponha-os no ponto mais alto que conseguir. Quanto menos seams na base de código, melhor; o ideal é um.

   Não os confirme separadamente: eles vão ao usuário no lote único descrito acima, e os seams acordados são escritos em Testing Decisions da especificação.

4. Escreva a especificação usando o modelo abaixo e publique-a no destino resolvido no passo 1. Aplique o rótulo de triagem `ready-for-agent`: não é preciso triagem adicional. (Para **markdown local**, "aplicar um rótulo" significa escrever uma linha `Status: ready-for-agent` perto do topo do arquivo.)

<destination-conventions>

- **GitHub**: `gh issue create --title "..." --body "..."` (heredoc para o corpo de várias linhas). Rótulos de triagem via `--label`.
- **GitLab**: `glab issue create --title "..." --description "..."` (heredoc para a descrição de várias linhas). Rótulos de triagem via `--label`.
- **Markdown local**: escreva `.scratch/<feature-slug>/SPEC.md`, criando o diretório se necessário. Registre o estado de triagem como uma linha `Status:` perto do topo do arquivo, em vez de um rótulo.

</destination-conventions>

<spec-template>

## Problem Statement

O problema que o usuário enfrenta, da perspectiva dele.

## Solution

A solução para o problema, da perspectiva do usuário.

## User Stories

Uma lista numerada e EXTENSA de histórias de usuário. Cada história de usuário deve estar no formato:

1. Como <ator>, quero <funcionalidade>, para que <benefício>

<user-story-example>
1. Como cliente de um banco mobile, quero ver o saldo das minhas contas, para que eu possa tomar decisões mais bem informadas sobre meus gastos
</user-story-example>

Esta lista de histórias de usuário deve ser extremamente abrangente e cobrir todos os aspectos da funcionalidade.

## Implementation Decisions

Uma lista das decisões de implementação tomadas. Pode incluir:

- Os módulos que serão construídos ou modificados
- As interfaces desses módulos que serão modificadas
- Esclarecimentos técnicos do desenvolvedor
- Decisões arquiteturais
- Mudanças de schema
- Contratos de API
- Interações específicas

NÃO inclua caminhos de arquivo específicos nem trechos de código. Eles podem ficar desatualizados muito rápido.

Exceção: se um protótipo produziu um trecho que codifica uma decisão com mais precisão do que a prosa consegue (máquina de estados, reducer, schema, formato de tipo), inclua-o dentro da decisão relevante e observe brevemente que veio de um protótipo. Reduza ao essencial das partes ricas em decisão, não uma demo funcional; apenas os pontos importantes.

## Testing Decisions

Uma lista das decisões de teste tomadas. Inclua:

- Uma descrição do que torna um bom teste (teste apenas o comportamento externo, não detalhes de implementação)
- Os seams acordados, um por item, para que `/to-tickets` e `/tdd` possam usá-los
- Quais módulos serão testados
- Precedentes para os testes (ou seja, tipos semelhantes de teste já existentes na base de código)

## Out of Scope

Uma descrição das coisas que estão fora do escopo desta especificação.

## Further Notes

Quaisquer outras observações sobre a funcionalidade.

</spec-template>
