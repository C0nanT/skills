```yaml
name: writing-shape
description: "Escrita, fase de exploit: molde material bruto em um artigo, parágrafo por parágrafo."
disable-model-invocation: true
```

<o-que-fazer>

O usuário passou (ou vai passar) um arquivo markdown de material bruto. Trate-o como a pilha de entrada: desde uma lista organizada de fragmentos até uma parede de prosa não estruturada ou uma transcrição. O formato não importa. Leia tudo, do início ao fim, antes de fazer qualquer outra coisa.

Depois, conduza uma sessão de modelagem que produza um documento de artigo separado. Esta é a **exploit**: a exploração já foi feita, a pilha está fixa: comprometa-se com uma estrutura e garimpe a pilha para preenchê-la. Não edite o arquivo de material bruto: ele é somente leitura para esta skill.

Se o usuário não tiver dito onde salvar o artigo, pergunte uma vez e lembre o caminho.

</o-que-fazer>

<informações-de-apoio>

## O ciclo

1. **Leia a pilha.** Leia o arquivo de entrada por inteiro. Forme uma ideia do que há nele.
2. **Estabeleça os pré-requisitos.** Defina com o usuário o que o leitor sabe ao chegar: os conceitos que estão **fundamentados** desde o início. Todo o resto precisa ser fundamentado por um bloco antes que um bloco posterior possa se apoiar nele. Veja [Fundamentação](#fundamentação).
3. **Rascunhe de 2 a 3 aberturas candidatas.** Cada abertura deve sugerir uma tese ou um ângulo diferente para o artigo. Mostre todas. Force o usuário a escolher ou a compor um híbrido. A abertura escolhida define o que o resto do artigo precisa fazer.
4. **Cresça parágrafo por parágrafo.** Depois que a abertura se firmar, pergunte "dada esta abertura, o que o leitor precisa ouvir a seguir?" Tire material da pilha para responder. O próximo bloco só pode se apoiar em conceitos fundamentados, e fundamenta novos conforme se firma. Discuta a forma que o próximo bloco deve ter: um parágrafo, uma lista, uma tabela, um callout, uma citação, um bloco de código. Cada escolha de formato deve ser deliberada e defensável.
5. **Acrescente ao arquivo do artigo à medida que avança.** Não acumule em lote. Grave cada parágrafo ou bloco acordado imediatamente, para que o usuário veja o artigo tomando forma.
6. **Repita o passo 4 até o artigo estar pronto.** O usuário decide quando ele está pronto.

## Fundamentação

Todo **conceito** precisa ser **fundamentado** antes que um bloco possa se apoiar nele: o leitor ou entrou já sabendo, ou o encontrou em um bloco anterior. Um bloco que alcança um conceito não fundamentado perde o leitor. A unidade é o conceito, não a palavra que o nomeia: um bloco pode se apoiar em uma ideia que o leitor não tem, mesmo sem nenhum jargão à vista. Quando um conceito tem nome (um **termo**), fundamentá-lo significa apresentar a ideia e o termo juntos.

Um conceito é fundamentado de duas maneiras:

- **Pré-requisito**: fundamentado antes da abertura. O leitor o traz. Definido no início.
- **Introduzido**: um bloco o estabelece, e a partir daí ele está fundamentado para o resto do artigo.

Mantenha uma lista corrente do que já está fundamentado. Quando você perguntar "o que o leitor precisa ouvir a seguir?", um conceito não fundamentado que o próximo movimento exige é, ele próprio, a resposta: fundamente-o primeiro (aqui ou em um bloco anterior), ou não consegue fazer o movimento. Esta é a identificação de lacunas de [Garimpar a pilha](#garimpar-a-pilha), um nível acima: ali a pilha está faltando material; aqui, o artigo está faltando uma base.

A alavanca é o que você torna pré-requisito versus o que fundamenta dentro do artigo. Exigir demais logo de início afasta leitores; fundamentar demais dentro do artigo afoga a abertura em definições. Defina isso com o usuário ao estabelecer os pré-requisitos.

## Sensação de conversa

Esta é uma sessão de grilling invertida. Na ideação, a pergunta era "o que você está de fato notando?". Aqui é "o que este artigo está de fato argumentando, e em que ordem o leitor precisa ouvir isso?". Resista. Recuse-se a deixar transições fracas passarem. Se um parágrafo não merece seu lugar, corte-o.

Movimentos específicos para continuar usando:

- "O que este parágrafo faz pelo leitor que o anterior não fazia?"
- "Se eu cortar isto, o que quebra?"
- "Isto é prosa, ou deveria ser uma lista? Por que prosa?"
- "Esta frase está fazendo dois trabalhos: divida-a ou escolha um."
- "A abertura prometeu X. Nós derivamos para Y. Ou reamarre o texto, ou mude a abertura."

## Garimpar a pilha

Trate o material bruto como uma pedreira, não como um roteiro. Pegue um fragmento, retrabalhe-o para se encaixar no parágrafo ao redor e coloque-o. Um fragmento pode ser dividido em vários parágrafos, fundido com outro ou parafraseado. O trabalho da pilha é ser minerada; o trabalho do artigo é ser lido como uma só voz.

Se a pilha não tiver algo de que o artigo precisa, nomeie a lacuna explicitamente: "Precisamos de um exemplo aqui e a pilha não tem um. Me dê um agora ou cortamos esta seção."

## Argumentos de formato para realmente ter

Ao escolher como renderizar um bloco, pese estas trocas em voz alta com o usuário, não em silêncio:

- **Prosa versus lista.** A prosa carrega argumento; listas carregam itens paralelos. Se os itens não forem realmente paralelos, prosa é melhor. Se forem, uma lista é mais rápida de escanear.
- **Inline versus callout.** Dicas, avisos e apartes vão em callouts (`> [!TIP]`, `> [!NOTE]`), mas somente se de fato desviariam o argumento principal se ficassem inline. Caso contrário, deixe-os inline.
- **Tabela versus estrutura repetida.** Se a mesma forma se repete 3 vezes ou mais com os mesmos campos, uma tabela. Caso contrário, prosa com negritos no início.
- **Citação versus paráfrase.** Cite quando a redação original é o ponto. Parafraseie quando só a ideia importa.
- **Bloco de código versus código inline.** Múltiplas linhas, executável ou ilustrativo → bloco. Um único token ou identificador → inline.

## Ritmo de escrita

Acrescente ao arquivo do artigo à medida que cada bloco for acordado. Releia o arquivo a partir do disco antes de cada gravação: o usuário pode ter editado entre os turnos. Nunca sobrescreva às cegas. Se o usuário quiser um parágrafo reescrito, edite esse parágrafo específico no lugar; deixe o resto intocado.

## Fora do escopo

- Garimpar fragmentos novos que não estão na pilha (trate as lacunas como em "Garimpar a pilha").
- Editar o arquivo de material bruto.
- Publicar, formatar para uma plataforma específica ou acrescentar frontmatter que o usuário não pediu.

</informações-de-apoio>
