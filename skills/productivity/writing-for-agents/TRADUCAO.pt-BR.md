```yaml
name: writing-for-agents
description: Escrita de documentos para agentes. Use ao criar ou editar skills, ou ao modificar AGENTS.md ou CLAUDE.md.
```

Referência para escrever qualquer documento que um agente consome: uma skill, um `AGENTS.md` / `CLAUDE.md`, um documento alcançado por um ponteiro. A embalagem muda; a escrita não: as mesmas alavancas tornam cada um previsível, já que o agente segue o mesmo *processo* a cada execução em vez de produzir sempre a mesma saída.

Quando o documento que você está escrevendo for uma skill, leia [`SKILL-MECHANICS.pt-BR.md`](SKILL-MECHANICS.pt-BR.md) para o frontmatter, a escolha de invocação e as skills roteadoras.

## Ponteiros de contexto

Um **ponteiro de contexto** é uma referência mantida no contexto do agente que nomeia algum material fora do contexto e codifica a condição para alcançá-lo. A descrição de uma skill é um; uma linha do `AGENTS.md` que nomeia um documento é o mesmo objeto. A *redação* do ponteiro, não o seu alvo, decide quando o agente alcança o material e com que confiabilidade. Um alvo indispensável atrás de um ponteiro mal redigido é um bug de variância: afine a redação primeiro, e só traga o material para dentro se afinar não bastar.

Um ponteiro faz dois trabalhos: dizer o que o material é, e listar os **ramos** que devem disparar a busca por ele (um ramo é um caso distinto que o documento trata, de modo que execuções diferentes percorrem caminhos diferentes). Cada palavra de um ponteiro sempre carregado custa em todo turno, então ele merece uma poda ainda mais rigorosa que o corpo:

- **Coloque a palavra-guia no início**: o ponteiro é onde ela faz o trabalho de disparo.
- **Um gatilho por ramo.** Sinônimos que renomeiam um único ramo são o mesmo ramo escrito duas vezes; junte-os e mantenha só os ramos genuinamente distintos.
- **Corte a identidade que o corpo já carrega.**

## As duas cargas

Todo documento e todo ponteiro que você acrescenta gasta um de dois orçamentos:

- **Carga de contexto** é o custo do material sempre carregado na janela do agente: uma linha do `AGENTS.md`, a descrição de uma skill, qualquer coisa que fique no contexto a cada turno, gastando tokens e atenção esteja ela disparando ou não.
- **Carga cognitiva** é o custo para o humano: quais documentos existem e quando recorrer a cada um. O humano é o índice. Não é um custo a minimizar: é o preço da agência humana; gaste-o onde o julgamento humano importa, remova-o onde não importa.

Material alcançado apenas por um ponteiro escapa da carga de contexto, ao preço da própria linha do ponteiro; material sem ponteiro algum depende inteiramente da carga cognitiva.

## Hierarquia de informação

Um documento é construído a partir de dois tipos de conteúdo: **passos** (as ações ordenadas que o agente executa) e **referência** (definições, regras, fatos consultados sob demanda). Os dois se misturam livremente: só passos (uma receita), só referência (as regras de uma revisão, esta skill), ou ambos. A decisão central é onde cada pedaço fica na **hierarquia de informação**, uma escada ordenada por quão imediatamente o agente precisa do material:

1. **Passo no próprio arquivo** é o nível primário: o que o agente faz, em ordem.
2. **Referência no próprio arquivo** é consultada sob demanda. Muitas vezes é um conjunto plano de pares legítimo (todas as regras de uma revisão em um único degrau), o que é um bom arranjo, não um cheiro ruim.
3. **Referência divulgada** é empurrada para um arquivo separado, alcançado por um ponteiro de contexto, carregado só quando o ponteiro dispara. Vai de um arquivo irmão na mesma pasta até a referência totalmente externa, que pode estar em qualquer lugar e para a qual qualquer documento pode apontar.

Empurre pouco para baixo e o topo incha; empurre demais e você esconde o material de que o agente de fato precisa. Essa tensão é a decisão inteira.

**Divulgação progressiva** é o movimento para baixo na escada (para fora do arquivo principal e atrás de um ponteiro), de modo que o topo continue legível. Não é primariamente uma otimização de tokens: é como a hierarquia é protegida. A ramificação é o teste mais limpo de divulgação: coloque no próprio arquivo o que todo ramo precisa, e empurre atrás de um ponteiro o que só alguns ramos alcançam. Quando um documento tem passos, referência no próprio arquivo que deveria estar divulgada enterra os passos e transforma prestar atenção neles numa moeda ao ar: uma alavanca de variância, não só de legibilidade.

**Co-localização** é a companheira dentro do arquivo: onde a escada decide *quão fundo* um pedaço fica, a co-localização decide *o que fica ao lado* dele depois de lá. Mantenha a definição, as regras e as ressalvas de um conceito sob o mesmo título, em vez de espalhadas, para que ler uma parte traga consigo os vizinhos. O teste: o documento deve ler-se como documentação escrita para o agente. Material agrupado lê-se assim; material espalhado não. (Diferente da duplicação: esta repete um significado em dois lugares; espalhar fragmenta um significado por muitos.)

**Inchaço** é o modo de falha aqui: um documento simplesmente longo demais, mesmo que cada linha esteja viva e seja única. A atenção se dilui no excesso, e cada linha extra é mais uma a manter relevante. A cura é a escada: divulgue referência atrás de ponteiros, e divida por ramo ou sequência para que cada caminho carregue só o que precisa.

## Passos e critérios de conclusão

Todo passo termina em um **critério de conclusão**, a condição que diz ao agente que o trabalho está pronto. Duas propriedades o tornam uma alavanca:

- **Clareza**: o agente consegue distinguir o concluído do não concluído? Um limite vago ("entendimento alcançado") convida à **conclusão prematura**: encerrar o passo antes de ele estar de fato pronto, com a atenção escorregando para *estar pronto*. Os passos visíveis que ainda faltam (os **passos pós-conclusão**) fornecem a atração; a clareza do critério é a resistência. Defenda-se nesta ordem: **afine o limite primeiro** (local e barato); só se ele for irredutivelmente vago *e* você observar a pressa, esconda os passos posteriores dividindo a sequência. Esconder só funciona através de uma fronteira de contexto real (um handoff ou o despacho de um subagente; uma chamada inline deixa os passos posteriores no contexto e não limpa nada).
- **Exigência**: quanto ele demanda. "Every modified model accounted for" força um trabalho minucioso onde "produce a change list" não força. A exigência dirige o **trabalho braçal** (a escavação que o agente faz dentro do trabalho, latente na redação em vez de escrita como passo próprio), e não está presa a passos: "every rule applied" vincula um corpo de referência plana do mesmo jeito que "every step done" vincula uma sequência, e é assim que um documento só de referência ainda carrega uma barra de exaustividade.

Os critérios mais fortes são ao mesmo tempo verificáveis e exaustivos.

## Quando dividir

Dividir um documento em dois gasta uma das duas cargas, então divida só quando o corte compensar:

- **Por sequência**: divida uma sequência de passos quando os passos pós-conclusão tentarem o agente a apressar o que está à frente. Mantê-los fora de vista aumenta o trabalho braçal na tarefa atual. Cuidado com o inverso: fundir sequências expõe cada passo aos passos seguintes, convidando à conclusão prematura.
- **Por invocação**, específico de skill: veja [`SKILL-MECHANICS.pt-BR.md`](SKILL-MECHANICS.pt-BR.md).

## Palavras-guia

Uma **palavra-guia** é um conceito compacto que já vive no pré-treinamento do modelo e com o qual o agente pensa enquanto executa o documento (_lesson_, _fog of war_, _tracer bullets_). Repetida como um token, nunca como uma frase, ela acumula uma definição distribuída e ancora uma região inteira de comportamento com o menor número de tokens, recrutando priors que o modelo já tem. Cunhar a sua própria funciona se você a definir com clareza, mas uma palavra inventada não recruta prior nenhum: você paga em tokens de definição o que uma palavra pré-treinada dá de graça; procure primeiro uma palavra existente.

Ela ancora duas vezes. No corpo, *execução*: o agente recorre ao mesmo comportamento toda vez que a palavra aparece, e, dentro de uma referência plana, ela foca a atenção em uma classe de coisa a procurar. Em um ponteiro, *invocação*: quando a mesma palavra aparece nos seus prompts, nos seus documentos e no seu código, o agente liga essa linguagem compartilhada ao material e o alcança com mais confiabilidade.

Procure oportunidades de refatorar com palavras-guia. Uma tríade soletrada em três lugares, um ponteiro que gasta uma frase para aludir a uma ideia. Cada um é um trecho pedindo para colapsar em um único token:

- "rápido, determinístico, de baixo overhead" → _tight_ (um loop _tight_).
- "um loop em que você acredita" → _red_, transformando um portão difuso em um estado observável binário (o loop fica _red_ no bug, ou não fica).

Você ganha duas vezes: menos tokens, e um gancho mais afiado para o agente pendurar o pensamento. Presuma que todo documento carrega repetições que as palavras-guia aposentam. Vá encontrá-las.

**Negação** é o modo de falha ao lado desta alavanca: dirigir por proibição arrasta o comportamento proibido para o contexto e o torna *mais* disponível, não menos. _Não pense num elefante_, e o elefante é tudo o que existe; a negação é um modificador fraco que o conceito fortemente ativado atropela, então a proibição se lê pela metade como instrução para fazer a coisa. Peça o **positivo**: declare o comportamento-alvo ("escreva comentários de uma linha") para que o comportamento proibido nunca seja mencionado. Uma proibição só se justifica como uma barreira rígida que você não consegue formular positivamente; mesmo assim, combine-a com o alvo positivo para que a atenção caia sobre o que fazer.

## Poda

- Mantenha cada significado em uma **fonte única da verdade**: um lugar autoritativo, para que mudar o comportamento seja uma edição em um só lugar. **Duplicação** (o mesmo significado em mais de um lugar) custa manutenção e tokens, e infla a proeminência de um significado além do seu degrau real na escada. (O inverso acidental de uma palavra-guia, que repete um token de propósito, nunca o significado.)
- O **ambiente** também é uma fonte da verdade (scripts do `package.json`, arquivos de configuração, o layout de diretórios, a saída do `--help`), e um documento que o reescreve é um **cache**: uma cópia de uma consulta, que só se justifica quando a consulta é cara. Faça cache do que o agente não consegue descobrir olhando: a convenção não escrita, a razão por trás de uma escolha, a armadilha que nenhuma configuração confessa. Deixe as consultas de um arquivo, um comando para o ambiente, onde não podem ficar desatualizadas.
- Verifique cada linha quanto à **relevância**: ela ainda diz respeito ao que o documento faz? Uma linha perde relevância por nunca dizer respeito à tarefa (mera exposição, ou um ramo que deveria estar divulgado) ou por ficar desatualizada conforme o comportamento ou o mundo que ela descreve mudam. Documentos menores são mais fáceis de manter relevantes. Sem uma disciplina de poda, o destino padrão é a **sedimentação**: camadas obsoletas que se acomodam porque acrescentar parece seguro e remover parece arriscado, até você precisar escavar por elas para achar o que ainda está vivo.
- Caça a **não-operações** frase por frase: uma instrução que o modelo já obedece por padrão paga carga para não dizer nada. O teste (muda o comportamento em relação ao padrão?) é relativo ao modelo, não ao leitor: duas pessoas que discordam sobre uma não-operação discordam sobre o padrão, e isso se resolve rodando o documento, não debatendo. Quando uma frase falha, apague a frase inteira em vez de aparar palavras dela. O teste também avalia palavras-guia: uma palavra fraca demais para vencer o padrão (*seja minucioso* quando o agente já é minucioso-ish) é uma não-operação, e a correção é uma palavra mais forte (*implacável*), não uma técnica diferente.
