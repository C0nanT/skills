# Limites de fase

Uma **fase** é um bloco de trabalho dentro de uma sessão: o grilling, a implementação, o QA. A definição é vaga de propósito: uma fase termina quando você pensa _"ok, terminamos com isso"_.

O **limite de fase** é o intervalo entre duas fases, e é o único lugar onde esta decisão pertence. No meio de uma fase não há decisão a tomar: continue, ou divida o trabalho restante em subagentes. Compactar no meio de uma fase faz o agente perder o fio da meada.

## As cinco opções

| Opção        | O que faz                                                         |
| ------------ | ----------------------------------------------------------------- |
| **Continuar** | Permanecer na sessão. Nenhuma troca de contexto.                  |
| **`/clear`**  | Esvazia a janela de contexto e começa do zero.                    |
| **`/handoff`** | Escreve um arquivo markdown portável e alimenta uma sessão em qualquer lugar com ele. |
| **Subagente** | Envia a tarefa para a própria janela de contexto e recebe um relatório de volta. |
| **`/compact`** | Comprime este contexto e alimenta uma sessão nova com o resumo.   |

## A árvore

Percorra de cima para baixo no limite. O primeiro **sim** vence.

**1. Você pode continuar nesta sessão?** Duas coisas tornam a resposta sim: a fase seguinte precisa desta fase como **fonte primária**, ou você ainda tem [smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone) suficiente (cerca de 150 mil tokens) para que a fase seguinte caiba. Grilling → implementação é o sim padrão: a implementação quer o raciocínio literal, não um resumo dele. Continuar não custa nada e não perde nada, então descarte essa opção antes de qualquer outra.

**2. O contexto é irrelevante para o que vem a seguir?** Tudo nesta sessão (a exploração, as decisões, os becos sem saída) é descartável? Se sim, **`/clear`**. É a jogada mais barata do tabuleiro: não leva tempo e devolve a janela inteira. O `/clear` também não é definitivo: a sessão antiga continua retomável.

O custo de errar aqui é de mão única. Limpar um contexto _relevante_ faz você perder o **porquê** do que foi construído, e nenhuma quantidade de releitura do diff o devolve.

**3. Você precisa fazer handoff?** O `/handoff` é restrito. Você só precisa dele quando estiver:

- trocando para um **novo harness** (Claude → Codex),
- mudando para um **novo diretório** ou repositório,
- enviando o trabalho para um **colega**,
- ou bifurcando uma tarefa paralela que encontrou **no meio de uma fase**, sem desviar do que está fazendo.

Essa lista é a cláusula inteira. O que o `/handoff` compra é **portabilidade**: um arquivo que viaja. Se nada está viajando, você não precisa dele.

**4. A tarefa pode ser feita AFK?** Ela está delimitada o bastante para rodar com você longe do teclado, sem direcionamento? Então envie-a a um **subagente** e deixe esta sessão intocada. Revisão automatizada é o caso padrão: o agente lê o diff e relata, e você não é necessário enquanto ele faz isso.

**5. Caso contrário, `/compact`.** Contexto relevante, mesmo harness, mesmo diretório, e você precisa continuar no circuito: é aqui que a árvore termina, e termina aqui com frequência. Passe uma instrução (`/compact we're going to QA this area`) para que o resumo mantenha o que a fase seguinte precisa.

`/compact` é o **padrão, não a primeira escolha**. Ele fica no fim porque as quatro perguntas acima dele são todas mais baratas ou mais precisas. O modo de falha, quando as pessoas começam por aqui, é uma sessão nova confiantemente errada sobre uma decisão que o resumo achatou.

## Fontes primárias e secundárias

Toda jogada exceto **Continuar** transforma uma **fonte primária** em uma **fonte secundária**: a sessão como aconteceu, substituída por um resumo dela. A troca tem sempre a mesma forma:

| Fonte                              | Informação | Ruído | Espaço de manobra |
| ---------------------------------- | ---------- | ----- | ----------------- |
| Primária (Continuar)               | Completa   | Muito | Pouco             |
| Secundária (`/compact`, `/handoff`) | Com perdas | Menos | Muito             |

É por isso que a pergunta 1 vem primeiro. Você só paga a perda de informação quando ficar parado custa mais do que economiza.

## Estas são decisões de julgamento

As perguntas não são objetivas: cada uma tem um pouco de gosto pessoal, e o mesmo limite pode ir para dois lados em dois dias diferentes. O valor está em fazê-las **na ordem**, no limite, e não no meio do trabalho.
