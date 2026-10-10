```yaml
name: wayfinder
description: Planeje um trabalho enorme (maior do que uma sessão de agente comporta) como um mapa compartilhado de tickets de decisão no seu issue tracker, e resolva-os um de cada vez até que o caminho até o destino esteja claro.
disable-model-invocation: true
```

Uma ideia solta chegou, grande demais para uma sessão de agente, envolta em névoa: o caminho de onde você está até o **destino** ainda não é visível. Wayfinding é sobre encontrar esse caminho, não sobre correr em direção ao destino. Esta skill desenha o caminho como um **mapa compartilhado** no issue tracker do repositório, depois trabalha os seus **tickets de decisão** (perguntas cuja resolução é uma decisão, não fatias de uma construção a executar) um de cada vez, até que a rota esteja clara.

O destino varia conforme o esforço, e nomeá-lo é o primeiro ato de desenhar o mapa, porque ele molda cada ticket. Pode ser uma especificação a entregar e iterar, uma decisão a travar antes do planejamento começar, ou uma mudança feita no lugar, como a migração de uma estrutura de dados. O mapa é independente de domínio: trabalho de engenharia, conteúdo de curso, o que couber nesse formato.

## Planeje, não faça

Wayfinder é **planejamento** por padrão: cada ticket resolve uma decisão, e o mapa está pronto quando o caminho está claro, sem nada a decidir antes de alguém ir fazer a coisa. A vontade de simplesmente fazer o trabalho costuma ser o sinal de que você chegou à borda do mapa e é hora de passar adiante. Um esforço pode sobrepor isso nas suas **Notes**, levando a execução para dentro do próprio mapa, mas, sem isso, produza decisões, não entregas.

## Refira-se pelo nome

Todo mapa e todo ticket é uma issue, então tem um **nome**: o seu título. Em tudo o que o humano lê (narração, as Decisions-so-far do mapa), refira-se a ele pelo nome, nunca por um id, número ou slug nu. Um muro de `#42, #43, #44` é ilegível; nomes se leem de relance. O id e a URL não desaparecem; um nome envolve o link, e eles ficam _dentro_ do nome, nunca no lugar dele.

## O Mapa

O mapa é uma única issue no issue tracker deste repositório, com o rótulo `wayfinder:map`, o artefato canônico. Os tickets dele são issues filhas do mapa.

O mapa é um **índice**, não um depósito. Ele lista as decisões tomadas e aponta para os tickets que guardam o detalhe; uma decisão vive em exatamente um lugar, o seu ticket, então o mapa nunca a repete, só a resume e linka.

**Onde o mapa, os tickets filhos, os bloqueios e as consultas de fronteira vivem fisicamente depende do tracker.** O issue tracker deveria ter sido fornecido a você: rode `/setup-skills` se não tiver sido. Consulte a seção "Wayfinding operations" do documento do tracker para saber como _este_ repositório expressa isso. Se nenhum tracker tiver sido fornecido, use por padrão o tracker de markdown local.

### O corpo do mapa

O mapa inteiro em baixa resolução, carregado uma vez por sessão. Tickets abertos **não** são listados: eles são issues filhas abertas, encontradas por consulta.

```markdown
## Destination

<what reaching the end of this map looks like: the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link): <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

### Tickets

Cada ticket é uma **issue filha** do mapa; o id da issue no tracker é a identidade dele. O corpo é a pergunta, dimensionada para uma sessão de agente de 100 mil tokens:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Cada ticket carrega um rótulo `wayfinder:<type>`, um de `research`, `prototype`, `grilling`, `task` (veja [Tipos de ticket](#tipos-de-ticket)). Os rótulos `wayfinder:` são os únicos que um mapa e seus tickets carregam, nunca um rótulo de triagem como `ready-for-agent`: eles são decisões, não trabalho de implementação.

Uma sessão **reivindica** um ticket atribuindo-o ao dev que conduz o mapa, **primeiro**, antes de qualquer trabalho, para que sessões concorrentes o pulem. Esse responsável _é_ a reivindicação: um ticket aberto e sem responsável está desreivindicado.

O bloqueio usa a relação de dependência **nativa** do tracker: essencial porque ela desenha a fronteira _visualmente_ na própria interface do tracker, para que o humano veja o que pode ser pego sem abrir o mapa. Só um tracker sem bloqueio nativo recorre a uma convenção no corpo. Um ticket está **desbloqueado** quando todos os tickets que o bloqueiam estão fechados; a **fronteira** são os filhos abertos, desbloqueados e não reivindicados, a borda do conhecido.

A resposta não faz parte do corpo; ela é registrada na resolução (veja [Percorrer o mapa](#percorrer-o-mapa)). Artefatos criados durante a resolução de um ticket são linkados a partir da issue, não colados nela.

## Tipos de ticket

Todo ticket é **HITL** (human in the loop, trabalhado _com_ um humano que fala por si) ou **AFK**, conduzido só pelo agente. Um ticket HITL só se resolve por essa troca ao vivo; o agente nunca responde pelo lado do humano nessa troca (um agente de grilling que responde às próprias perguntas quebrou essa regra).

- **Research** (AFK): ler documentação, APIs de terceiros ou recursos locais como bases de conhecimento para trazer um fato do qual uma decisão depende. Resolvido por um **subagente** que chama a ferramenta Skill com "research". Use quando for preciso conhecimento fora do diretório de trabalho atual.
- **Prototype** (HITL): elevar a fidelidade da discussão criando um artefato barato, rústico e concreto para reagir, um esboço, uma versão rápida, um stub, ou código de UI ou lógica, via ferramenta Skill com "prototype". Linka o protótipo como um asset. Use quando "como deveria parecer" ou "como deveria se comportar" é a pergunta-chave.
- **Grilling** (HITL): conversa, uma pergunta de cada vez. O caso padrão. Sempre chame a ferramenta Skill com "grilling".
- **Task** (HITL ou AFK): trabalho manual que precisa acontecer antes de uma _decisão_ poder ser tomada: nada a decidir, prototipar ou pesquisar, mas a discussão está bloqueada até que isso seja feito. Cadastrar-se num serviço para que sua API possa ser avaliada, provisionar acesso, mover dados para que seu formato possa ser visto. Este é o único tipo que _faz_ em vez de decidir, e só se justifica por desbloquear uma decisão, não por entregar o destino. O agente conduz sozinho onde puder (AFK); caso contrário, entrega ao humano um checklist preciso (HITL). Resolvido quando o trabalho está feito; a resposta registra o que foi feito e quaisquer fatos resultantes (local das credenciais, novas URLs, contagens de linhas) dos quais tickets posteriores dependem.

## Névoa de guerra

O mapa é _deliberadamente_ incompleto: não desenhe o que você ainda não consegue ver. Além dos tickets vivos está a **névoa de guerra**: a visão tênue de decisões e investigações que você percebe que vêm, mas ainda não consegue fixar, porque dependem de perguntas ainda abertas. Resolver um ticket dissipa a névoa à frente dele, graduando o que agora pode ser especificado em tickets novos, um de cada vez, até que o caminho para o destino esteja claro e nenhum ticket reste.

A seção **Not yet specified** do mapa é onde essa visão tênue é anotada: a pergunta suspeita, a área a revisitar depois. É a fronteira ainda não descoberta _em direção_ ao destino: tudo aqui está no escopo, só não está nítido o bastante para virar ticket. Escreva com a frouxidão ou o detalhe que a visão permitir; ela também serve de sinalização para colaboradores que leem para onde o esforço está indo.

**Névoa ou ticket?** O teste é se você consegue enunciar a pergunta com precisão agora, _não_ se consegue respondê-la agora.

- **Ticket quando** a pergunta já está nítida, mesmo que esteja bloqueada e você ainda não possa agir sobre ela.
- **Not yet specified quando** você ainda não consegue formulá-la com essa nitidez. Não pré-fatie a névoa em pedaços do tamanho de ticket: ela é mais grossa do que um ticket, e um remendo pode se graduar em vários tickets, ou em nenhum, quando a fronteira chegar até ele.

**Not yet specified** exclui o que já está decidido (Decisions so far), o que já é um ticket vivo e o que está fora do escopo (a próxima seção).

## Fora de escopo

A névoa só se acumula _em direção_ ao destino. O destino fixa o escopo, então o trabalho além dele está **fora de escopo**: não é névoa e não pertence a **Not yet specified**. Ele ganha uma seção própria, **Out of scope**, no mapa: trabalho que você conscientemente excluiu _deste_ esforço. É o escopo, não a nitidez, que o coloca ali.

Trabalho fora de escopo nunca se graduá (a fronteira para no destino), então só volta se o destino for redesenhado, e aí como um esforço novo, não como uma retomada.

Excluir algo do escopo é um ato de delimitação, não um passo na rota. Quando um ticket que já existe se revela além do destino (mal escopado ao desenhar o mapa, ou exposto por uma resolução), **feche-o** (um ticket fechado está inequivocamente fora da fronteira) e deixe uma linha na seção **Out of scope**: a essência e o porquê de estar fora do escopo, linkando o ticket fechado. Ele fica fora de **Decisions so far**, que registra a rota efetivamente percorrida; um limite de escopo não é um passo nela.

## Invocação

Dois modos. Em ambos, **nunca resolva mais de um ticket por sessão**, com exceção dos tickets de pesquisa.

### Desenhar o mapa

O usuário invoca com uma ideia solta.

1. **Nomeie o destino.** Chame a ferramenta Skill com "grilling" para fixar aonde este mapa está tentando chegar: a especificação, a decisão ou a mudança. O destino fixa o escopo, então é resolvido primeiro.
2. **Mapeie a fronteira.** Faça o grilling de novo, desta vez **em largura**: espalhe-se pelo espaço inteiro em vez de ir fundo numa única linha, expondo as decisões abertas e os primeiros passos que podem ser dados agora. **Se isto não revelar nenhuma névoa** (o caminho até o destino já está claro, a jornada inteira é pequena o bastante para uma sessão), você não precisa de mapa. Pare e pergunte ao usuário como ele quer prosseguir.
3. **Crie o mapa** (rótulo `wayfinder:map`): Destination e Notes preenchidos, Decisions-so-far vazio, a névoa esboçada em **Not yet specified**.
4. **Crie os tickets que você consegue especificar agora** como issues filhas do mapa, depois conecte as arestas de bloqueio em uma **segunda passada** (issues precisam de ids antes de poderem se referenciar). Escreva as referências cruzadas nessa mesma passada, com ids reais: um placeholder `#<n>` vira link automático para uma issue não relacionada. A conexão ordena os tickets em fronteira e bloqueados; tudo o que você ainda não consegue especificar permanece na névoa: a seção **Not yet specified**.
5. **Dispare os subagentes de pesquisa.** Para cada ticket `research` que você acabou de criar, inicie um subagente que chama a ferramenta Skill com "research" para resolvê-lo em paralelo, capturando as descobertas num branch descartável `research/<name>` com um ponteiro de contexto a partir do ticket. Faça push do branch, mas não abra PR: ele nunca é mesclado.
6. Pare: desenhar o mapa é trabalho de uma sessão; ele não resolve nada à mão.

### Percorrer o mapa

O usuário invoca com um mapa (URL ou número). Um ticket é **opcional**: sem um, você escolhe a próxima decisão, não o usuário.

1. Carregue o **mapa**: a visão de baixa resolução, não o corpo de todos os tickets.
2. Escolha o ticket. Se o usuário nomeou um, use-o. Caso contrário, pegue o primeiro ticket da fronteira, na ordem. **Reivindique-o**: atribua-o a você mesmo antes de qualquer trabalho.
3. Resolva-o como o tipo que o seu rótulo `wayfinder:<type>` indica (veja [Tipos de ticket](#tipos-de-ticket)). Leia o rótulo, não só o corpo: o corpo nunca declara o tipo. **Aproxime-se conforme necessário**: busque o corpo completo de qualquer ticket relacionado ou fechado sob demanda; chame a ferramenta Skill para quaisquer skills que o bloco `## Notes` nomear. Na dúvida, chame a ferramenta Skill com "grilling".
4. Registre a resolução: publique a resposta como um **comentário de resolução**, **feche** a issue e **acrescente um ponteiro de contexto** às Decisions-so-far do mapa.
5. Adicione os tickets recém-surgidos (criar e depois conectar); gradue qualquer névoa que a resposta tenha tornado especificável, retirando cada remendo graduado de **Not yet specified** para que ele viva apenas como o novo ticket. Se a resposta revelar que um ticket (este ou outro) está além do destino, **exclua-o do escopo** em vez de resolvê-lo na rota. Se a decisão invalidar outras partes do mapa, atualize ou apague esses tickets.

O usuário pode rodar tickets desbloqueados em paralelo, então espere que outras sessões estejam editando o tracker ao mesmo tempo.
