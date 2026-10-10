```yaml
name: ask-skills
description: Pergunte qual skill ou fluxo se encaixa na sua situação. Um roteador sobre as skills deste repositório.
disable-model-invocation: true
```

# Perguntar sobre skills

Você não se lembra de todas as skills, então pergunte.

Antes de dizer o que uma skill faz ou de recomendar pular um passo, leia o SKILL.md dessa skill: os resumos aqui servem apenas para orientação.

Um **fluxo** é um caminho pelas skills. A maioria dos caminhos segue um **fluxo principal**, e uma **rampa de entrada** se integra a ele. Todo o resto é independente.

## O fluxo principal: ideia → entrega

O caminho que a maior parte do trabalho percorre. Você tem uma ideia e quer que ela seja construída.

1. **`/grill-with-docs`** afia a ideia por meio de entrevista. Comece aqui sempre que estiver **trabalhando em um diretório de trabalho**: ela é stateful, guarda o que aprende no `GLOSSARY.md` e nos ADRs. (Sem diretório de trabalho? Use `/grill-me`, descrita em Independentes. As duas usam a mesma primitiva `/grilling`; o `grill-with-docs` é a que deixa um rastro no papel, o que a torna a melhor das duas sempre que houver um repositório onde deixá-lo.)
2. **Ramificação: dá para resolver todas as perguntas na conversa?** Se uma pergunta precisa de uma resposta executável (estado, lógica de negócio, uma UI que você precisa ver), faça um desvio por um protótipo, com pontes de **`/handoff`** nos dois sentidos (um protótipo vive no próprio diretório, e é exatamente para isso que o `/handoff` serve; veja Limites de fase):
   - **`/handoff`** para sair, depois abra uma sessão nova com esse arquivo,
   - **`/prototype`** para responder à pergunta com código descartável,
   - **`/handoff`** de volta com o que você aprendeu, e referencie-o a partir da thread da ideia original.
3. **Ramificação: é uma construção de várias sessões?**
   - **Sim** → **`/to-spec`** (transforma a thread em uma especificação), depois **`/to-tickets`** para dividi-la em tickets de tracer bullet, cada um declarando suas **arestas de bloqueio**. Depois trabalhe os tickets de uma de duas formas:
     - **`/implement`** por ticket, **com `/clear` do contexto entre cada um**. Em um tracker local, é um arquivo por ticket em `.scratch/<feature>/tickets/`, trabalhados manualmente, primeiro os bloqueadores; em um tracker real, as arestas viram links nativos de bloqueio, então qualquer ticket cujos bloqueadores estejam concluídos pode ser pego. Cada ticket é autocontido, então o contexto do anterior é descartável. (`/delegate-tickets`, em Independentes, roda esse laço sem supervisão, um subagente por ticket.)
     - **`/implement-spec`** para a especificação inteira em uma única execução. Ela lê os tickets como um **grafo de tarefas**, roda subagentes implementadores sobre a **fronteira** de prontos em paralelo, junta tudo em um **branch de integração** e, em seguida, executa um único `/review-axes` sobre ele. Use quando preferir orquestrar a construção a conduzir cada ticket por conta própria.
   - **Não** → **`/implement`** aqui mesmo, na mesma janela de contexto.

   De um jeito ou de outro, o **`/implement`** constrói cada ticket conduzindo o **`/tdd`** internamente: uma fatia vermelho-verde por vez, roda a suíte completa, faz uma passada de refatoração sobre o próprio diff (desfeita se a suíte ficar vermelha) e então fecha executando o **`/review-axes`**, uma revisão de dois eixos (Standards + Spec) do diff, e termina fazendo commit do trabalho no branch atual. Use o **`/tdd`** sozinho quando quiser construir um comportamento concreto com teste primeiro, sem uma especificação completa, e o **`/review-axes`** sozinho sempre que quiser revisar um branch contra um ponto fixo. O `/review-axes` é para o **seu** trabalho: ele julga o diff pelos padrões que você segue e pela especificação que recebeu. Revisar o merge request **de outra pessoa** é um trabalho diferente: veja `/review-mr` em Independentes.

   Quando o trabalho vai para um pull request, o **`/pr`** dá forma ao corpo: o menor visual que mostra a mudança, evidências de antes e depois de que ela funciona, e uma classificação de porta de mão única ou de mão dupla. Ele é invocado pelo modelo, então o agente o usa sempre que escreve um PR.

4. **`/retro`** olha para trás depois que uma construção termina, especialmente depois de uma que saiu do rumo. Ela lê a sessão e sugere mudanças no **ambiente** do agente, não no código: ponteiros de navegação, checagens automatizadas, os padrões de código que o `/review-axes` aplica, arquivos de direcionamento, ferramentas. Erros mecânicos viram checagens determinísticas; julgamentos viram padrões de código. A próxima construção então começa de um ambiente melhor.

5. **`/archive-feature`** fecha o ciclo quando tudo estiver implementado. Em um tracker local, ela verifica pelos arquivos que cada ticket está `ready-for-human` (ou `done`) com todos os checkboxes marcados, mostra uma tabela-resumo e, depois de uma única confirmação, define a especificação e os tickets como `done` e move a funcionalidade inteira com `git mv` de `.scratch/` para `docs/archive/<feature-slug>/`. Passe o nome de uma funcionalidade ou o caminho da especificação, ou nada, para varrer todas as funcionalidades em `.scratch/`. Uma funcionalidade incompleta só é arquivada quando você a nomeia, com uma nota datada na especificação listando o que ficou de fora. Ela nunca marca um checkbox. Use-a quando perguntar "terminei de implementar, e agora?". Não se aplica a um tracker remoto.

### Higiene de contexto

Mantenha os passos 1 a 3 em **uma única janela de contexto ininterrupta** (não compacte nem limpe até depois do `/to-tickets`), para que o grilling, a especificação e os tickets se apoiem no mesmo raciocínio. Cada `/implement` então começa do zero, trabalhando a partir do ticket. Rode o `/retro` na sessão que ele vai analisar, antes de limpar; depois de limpar, aponte-o para o log dessa sessão.

O limite disso é a **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: a janela (cerca de 150 mil tokens nos modelos de ponta) dentro da qual o modelo ainda raciocina com nitidez. Se uma sessão se aproximar dela antes do `/to-tickets`, não force em um estado degradado; use `/compact` no limite de fase mais próximo e siga em frente (veja Limites de fase).

## Rampas de entrada

Uma situação inicial que gera trabalho, e depois se integra ao fluxo principal.

- **Um esforço enorme e nebuloso: um projeto do zero ou uma construção de funcionalidade grande demais para uma sessão** → **`/wayfinder`**, o fluxo mais exigente cognitivamente desta lista. Quando o caminho de onde você está até o destino ainda não é visível, ela desenha um **mapa compartilhado** de **tickets de decisão** no issue tracker e resolve um por vez, produzindo **decisões, não entregas**, até que a névoa recue e o caminho fique claro. Enquanto o **`/grill-with-docs`** afia uma ideia que cabe em uma sessão, o wayfinder é para a ideia que não cabe, e é mais lento e mais denso; guarde-o exatamente para isso, nunca para uma funcionalidade bem delimitada.

  Quando o mapa se esclarece, ele **entrega, não constrói**: integra-se ao fluxo principal em **`/to-spec`**, que reduz as decisões ligadas do mapa a um plano construível, depois `/to-tickets` e `/implement` como de costume. Ir do mapa direto para o `/implement` pula essa redução e descarta o detalhe ligado, então vá direto ao `/implement` só quando o esforço se revelar genuinamente pequeno. No caminho, seus tickets de **pesquisa** são resolvidos em paralelo por subagentes de `/research`, então a leitura braçal não espera por você.

## Saúde da base de código

Não é trabalho de funcionalidade, é só manutenção.

- **`/improve-codebase-architecture`**: rode sempre que tiver um momento livre para manter a base de código boa para os agentes operarem. Ela revela **oportunidades de aprofundamento**; escolher uma **gera uma ideia** que você pode levar ao fluxo principal em `/grill-with-docs`.

- **`/tech-debt-map`**: o levantamento mais amplo e mais frio, feito **um módulo por vez**. Ela descobre como o projeto se divide em módulos (declarando a própria partição quando o projeto não a tem), pergunta qual módulo revisar e mostra há quanto tempo cada um foi analisado pela última vez, depois varre esse módulo por todos os eixos (arquitetura, código, regras de negócio, manutenibilidade, testabilidade, performance, segurança) e deixa um **mapa de dívida**: no máximo 10 achados com evidências, ordenados por retorno em relação ao raio de impacto, seguidos de um plano incremental em três fases. É um **diagnóstico, não uma refatoração**, e não altera código, mas mantém um índice de revisão versionado em `docs/tech-debt/README.md`, para que um módulo que ninguém auditou há oito meses fique visível. Enquanto o `/improve-codebase-architecture` caça uma classe de problema e termina em uma sessão de grilling sobre um único candidato, esta termina em um arquivo que você percorre ao longo de semanas e que roda de novo para ver o que mudou. Suas linhas alimentam o `/to-spec` e depois o `/to-tickets`; uma linha cujo raio de impacto é Sistêmico alimenta o `/improve-codebase-architecture`.

## Limites de fase

Uma **fase** é um bloco de trabalho dentro de uma sessão: o grilling, a implementação, o QA. Em um **limite** entre duas delas você tem cinco opções, e escolher entre elas é a decisão mais nebulosa de todo este mapa:

- **Continuar**: fique onde está. Não custa nada, não perde nada.
- **`/clear`**: esvazia a janela, quando nada daqui importa para o que vem a seguir.
- **`/handoff`** escreve um arquivo markdown portável. É restrito: só para um **novo harness**, um **novo diretório**, um **colega**, ou para bifurcar uma tarefa paralela **no meio de uma fase**. O que ele compra é portabilidade.
- **Subagente**: envia uma tarefa com escopo bem restrito para a própria janela e recebe um relatório de volta.
- **`/compact`** comprime este contexto e alimenta uma sessão nova com ele. É o **padrão**, no fundo da árvore, e não a primeira escolha.

Leia [PHASE-BOUNDARIES.pt-BR.md](PHASE-BOUNDARIES.pt-BR.md) para a árvore ordenada: as cinco perguntas, o raciocínio por trás de cada ramo e por que o custo da fonte primária faz da **Continuar** a opção a descartar primeiro. Tome a decisão **no** limite; no meio de uma fase, continue ou divida o restante em subagentes.

## Independentes

Fora do fluxo principal.

- **`/grill-me`**: a mesma entrevista implacável do `/grill-with-docs`, mas **sem estado**: não salva nada localmente e não cria `GLOSSARY.md`. Use quando você **não estiver trabalhando em um diretório de trabalho** (afiar um plano, um design, um texto, qualquer coisa sem repositório por baixo). Se estiver em um diretório de trabalho, use `/grill-with-docs`: ela faz a mesma entrevista e deixa um rastro no papel, então é estritamente a melhor das duas.
- **`/grilling`**: a primitiva de entrevista em si: rodadas, a fronteira, os fatos são tarefa do agente e as decisões são suas. `/grill-me` e `/grill-with-docs` são as duas formas nomeadas de entrar, e `/wayfinder` e `/improve-codebase-architecture` a executam internamente. Use-a diretamente só quando quiser a entrevista sem nenhum invólucro em volta.
- **`/prototype`**: um programa pequeno e descartável que responde a uma pergunta de design: este modelo de estados parece correto, ou como esta UI deveria ser. Ser descartável é uma restrição sobre como o código é escrito, não uma promessa de destruí-lo: a resposta se incorpora ao código real, e o próprio protótipo é mantido como **fonte primária** em um branch `prototype/<name>` a partir da main, apontado a partir da issue de implementação. É o desvio do passo 2 do fluxo principal, mas use-o sempre que uma pergunta de design for difícil de resolver no papel.
- **`/research`**: delega o trabalho de leitura a um **agente em segundo plano**: ele investiga uma pergunta em **fontes primárias** e deixa um arquivo Markdown citado no repositório. Continue trabalhando enquanto ele lê. O arquivo que ele produz é algo a levar **para dentro** do fluxo principal em `/grill-with-docs`: a pesquisa alimenta o raciocínio, não o substitui.
- **`/frontend-handoff`**: a mudança foi entregue e outra equipe a consome. Lê a especificação e o diff, e emite um bloco pronto para colar cujo **veredito**, deve mudar / deveria mudar / nada é necessário, é a única coisa de que o dev de frontend precisa primeiro. Roda depois do `/implement` e responde "o front precisa tocar em alguma coisa?" sem uma reunião. Ela transmite apenas contexto; o trabalho de frontend em si é uma tarefa separada, no repositório deles.
- **`/to-questionnaire`**: quando o que está bloqueando você não está na sua cabeça nem na base de código, mas na de **outra pessoa**, ela escreve um questionário para essa pessoa preencher. É o inverso do `/grill-me`: em vez de entrevistar você sobre o assunto, entrevista você sobre o **envio**, para quem vai, o que você precisa de volta, e direciona as perguntas para a lacuna. O que volta é material para o `/grill-with-docs` ou o `/to-spec`.
- **`/wizard`**: para os passos que só um **humano** pode dar: provisionar infraestrutura, configurar credenciais ou secrets de CI, clicar em um painel de terceiros desconhecido, executar uma migração ou troca pontual. Ela gera um script bash interativo que abre cada URL, captura cada valor e o grava no `.env` e nos secrets do GitHub, para que o procedimento deixe de ser algo que você precisa explicar de novo a um agente toda vez. É invocada pelo modelo, então o agente a usa no momento em que bate em um muro que só você pode transpor. Se o agente conseguir fazer sozinho, ele deve fazer; isto é para quando um humano está de fato no circuito.
- **`/wait-what`**: o corretivo para uma mensagem que não foi compreendida. Use-o no meio da conversa, dentro de qualquer outra skill, e o agente refaz o que acabou de dizer com o contexto que você estava perdendo, em linguagem simples, usando o vocabulário do `GLOSSARY.md`. Ela funciona depois do fato; o `/grill-with-docs` é a cura preventiva, porque uma linguagem compartilhada combinada cedo é o que impede o jargão de chegar.
- **`/writing-for-agents`**: referência para escrever documentos que agentes consomem: skills, AGENTS.md, documentos apontados.
- **`/review-mr`**: revisa o merge request de outra pessoa (GitLab, GitHub ou dois branches locais) em busca de bugs, segurança, performance e design, confere o trabalho com os critérios de aceitação da tarefa e escreve um veredito (aprovar ou pedir alterações, e por quê) junto com os achados em um arquivo markdown local. Ela pergunta o que o diff não consegue responder antes de julgar. Enquanto o `/review-axes` julga o seu próprio diff pelos padrões e pela especificação do repositório, esta julga o de outra pessoa.
- **`/delegate-tickets`**: orquestra a implementação sequencial de tickets por meio de subagentes novos, um ticket por vez, cada um obrigado a rodar `/implement`. Use depois que o `/to-tickets` tiver produzido os tickets e você quiser que a construção rode sem supervisão em todos eles, com `/clear` do contexto entre cada um. Só roda tickets Standard e Light (em Sonnet, com esforço medium); um ticket Heavy, ou um sem linha `Difficulty:`, interrompe a execução para que você o faça manualmente. Ela também para, em vez de seguir em frente, sempre que um passo precisar de uma resposta humana.

## Pré-condição

- **`/setup-skills`**: rode antes do seu primeiro fluxo de engenharia para configurar o issue tracker, os rótulos de triagem, a organização dos documentos e as regras de negação do `.claude/settings.json` do projeto para git destrutivo. Trackers de issues customizados também funcionam.
- **`/setup-solid`**: opcional, uma vez por repositório. Escreve uma seção SOLID no `CLAUDE.md` que vincula todos os fluxos seguintes: no nível de arquitetura, independente de linguagem, e delimitada pela **regra do escoteiro** (boy scout rule). SOLID se aplica ao código novo e ao código que uma mudança já toca, então a base de código converge uma mudança por vez. Enquanto o `/improve-codebase-architecture` encontra uma refatoração a _fazer_, esta define o padrão com que o código é _escrito_.
