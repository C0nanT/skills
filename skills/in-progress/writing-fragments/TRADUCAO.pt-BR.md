```yaml
name: writing-fragments
description: "Escrita, fase de explore: extraia fragmentos brutos, ainda sem estrutura."
disable-model-invocation: true
```

<o-que-fazer>

Isto é **explore** puro: ampliar o espaço do que poderia ser escrito, sem se comprometer com uma estrutura. Comprometer-se é _exploit_, trabalho de outra skill. Conduza uma sessão de grilling que produza fragmentos, entrevistando o usuário de forma implacável sobre o que ele quer escrever. Impor fases, esboços ou estrutura de artigo está fora do escopo aqui.

À medida que os fragmentos surgirem de qualquer lado da conversa, acrescente-os a um único arquivo markdown.

Se o usuário não tiver passado um caminho, pergunte uma vez onde salvar o documento, e depois lembre-se dele durante toda a sessão.

Capture fragmentos desde a primeira coisa que o usuário disser, incluindo o prompt inicial.

Na primeira gravação, coloque um único H1 no topo com um título de trabalho (ele pode mudar depois) e nada mais: sem metadados, sem sumário, sem data.

</o-que-fazer>

<informações-de-apoio>

## O que é um fragmento

Um fragmento é qualquer trecho de texto que possa sobreviver até o artigo final. Ele precisa ser _legível pelo autor_ (o autor consegue dizer o que ele significa), mas não precisa definir seus termos nem ser compreensível para um leitor frio. O critério é "isto é um bom trecho de escrita?", não "isto é um argumento autocontido?"

Fragmentos são deliberadamente heterogêneos. Exemplos do que pode ser um fragmento:

- Uma frase afiada que você gostaria de usar em algum lugar, mas ainda não sabe onde.
- Uma afirmação com uma justificativa de uma linha.
- Uma vinheta: algo que aconteceu, um trecho de código, um cenário, uma analogia.
- Um meio pensamento: "algo sobre como X lembra Y, resolver isso depois."
- Uma citação, um trecho de diálogo, uma frase ouvida por acaso.
- Uma lista de observações relacionadas que se conectam pelo sentimento.
- Uma queixa, uma confissão, uma piada final.
- Uma **palavra-guia**: uma metáfora compacta ou um neologismo no qual a peça inteira pode se apoiar (um termo que nomeia a ideia, do jeito que _tracer bullets_ ou _fog of war_ nomeiam um padrão inteiro).

Desses, a palavra-guia é o fragmento mais valioso de registrar. Ela sustenta o texto: se você nomear a certa na fase de explore, ela molda a estrutura, as transições e o título depois, rendendo dividendos durante toda a fase de exploit. Quando a conversa rodear uma ideia recorrente, insista em cunhar uma palavra para ela.

O diário do romancista é o modelo: anos de observações não estruturadas que depois são garimpadas como matéria-prima. Fragmentos são observações.

## Formato do arquivo

```markdown
# Working title

A first fragment lives here.

It can be multiple paragraphs. It can include lists, code, quotes: whatever
shape the fragment naturally takes.

---

A second fragment.

---

> A quoted line that the user wants to keep around.

A reaction to it.

---

- A cluster of related observations
- That hang together by feel
- And want to be near each other
```

Os fragmentos são separados por uma linha horizontal (`\n---\n`). Nada de títulos dentro do corpo. Nada de tags. Nenhuma ordem além da ordem em que foram acrescentados.

## Ritmo de escrita

Acrescente em silêncio. Não peça permissão para cada fragmento. Mencione o que acrescentou de passagem ("adding that"), mas não interrompa a conversa com caixas de diálogo de salvamento.

Antes de cada gravação: releia o arquivo a partir do disco. O usuário pode ter editado, reordenado ou apagado fragmentos entre os turnos, então preserve as mudanças dele. Nunca sobrescreva o arquivo; apenas acrescente (ou, se o usuário pedir, edite um fragmento específico no lugar).

O usuário pode dizer "corte o último", "reescreva aquele mais afiado", "junte esses dois" a qualquer momento. Trate essas instruções como prioritárias.

</informações-de-apoio>
