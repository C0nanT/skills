```yaml
name: to-tickets
description: Divida um plano, uma especificação ou a conversa atual em um conjunto de tickets de tracer bullet, cada um declarando suas arestas de bloqueio, publicados no tracker configurado (arestas como texto, em um arquivo por ticket localmente, ou links nativos de bloqueio em um tracker real).
disable-model-invocation: true
```

# Para tickets

Divida um plano, uma especificação ou uma conversa em um conjunto de **tickets**: fatias verticais de tracer bullet, cada uma declarando os tickets que a **bloqueiam**.

Se rótulos de triagem ou convenções do tracker forem necessários e não existirem, rode `/setup-skills`. A resolução de destino abaixo não exige configuração.

## Processo

### 1. Reúna o contexto

Trabalhe a partir do que já estiver no contexto da conversa. Se o usuário passar uma referência (um caminho de especificação, um número ou URL de issue) como argumento, busque-a e leia o corpo completo e os comentários.

### 2. Explore a base de código (opcional)

Se ainda não tiver explorado a base de código, faça isso para entender o estado atual do código. Os títulos e as descrições dos tickets devem usar o vocabulário do glossário de domínio do projeto, e respeitar os ADRs da área que você está tocando.

Procure oportunidades de fazer uma pré-fatoração do código para facilitar a implementação. "Make the change easy, then make the easy change."

### 3. Rascunhe fatias verticais

Divida o trabalho em tickets de **tracer bullet**.

<vertical-slice-rules>

- Cada fatia atravessa um caminho estreito, mas COMPLETO, por todas as camadas (schema, API, UI, testes): vertical, NÃO uma fatia horizontal de uma única camada
- Uma fatia concluída é demonstrável ou verificável sozinha
- Cada fatia é dimensionada para caber em uma única janela de contexto nova
- Qualquer pré-fatoração deve ser feita antes de tudo

</vertical-slice-rules>

Dê a cada ticket as suas **arestas de bloqueio**: os outros tickets que precisam estar concluídos antes que ele possa começar. Um ticket sem bloqueadores pode começar imediatamente.

**Refatorações amplas são a exceção à fatia vertical.** Uma **refatoração ampla** é uma mudança mecânica (renomear uma coluna, retipar um símbolo compartilhado) cujo **raio de impacto** se espalha por toda a base de código, de modo que uma única edição quebra milhares de pontos de chamada de uma vez, e nenhuma fatia vertical consegue fechar verde. Não a force em um tracer bullet; sequencie-a como **expandir e depois contrair** (expand-contract). Primeiro expanda: adicione a nova forma ao lado da antiga, para que nada quebre. Depois migre os pontos de chamada em lotes, dimensionados pelo raio de impacto (por pacote, por diretório), cada lote sendo um ticket próprio bloqueado pela expansão, mantendo o CI verde de lote para lote porque a forma antiga ainda existe. Por fim, contraia: apague a forma antiga assim que nenhum chamador restar, em um ticket bloqueado por todos os lotes de migração. Quando nem os lotes conseguem ficar verdes sozinhos, mantenha a sequência, mas faça-os compartilhar um branch de integração, que todos bloqueiam um ticket final de integrar-e-verificar; o verde só é garantido ali.

### 4. Classifique a dificuldade de cada ticket

Dê a cada ticket um **nível de dificuldade** e um **modelo sugerido** para quem for pegá-lo. A sugestão é uma dica, nunca um requisito: quem lê pode estar no Claude Code, no Cursor ou em outro lugar, então nomeie um modelo por ferramenta e deixe que a pessoa substitua.

<difficulty-tiers>

| Nível | O que cai aqui | Modelo sugerido |
| --- | --- | --- |
| **Heavy** | Infraestrutura, deploys, migrações, decisões de arquitetura, fronteiras de segurança, refatorações amplas, qualquer coisa cujo raio de impacto cruze subsistemas | Opus (Claude Code) / Opus ou o modelo de raciocínio mais forte disponível (Cursor) |
| **Standard** | Lógica de programação comum: uma fatia de funcionalidade, um endpoint, um componente, uma correção de bug com ramificação real. O nível padrão, e onde a maioria dos tickets se encaixa | Sonnet (Claude Code) / Sonnet (Cursor) |
| **Light** | Trabalho mecânico, de baixo julgamento: atualização de configuração, mudanças de texto, renomeações com raio de impacto pequeno, adição de um teste que espelha um existente | Sonnet (Claude Code) / Sonnet (Cursor) |

</difficulty-tiers>

Classifique pelo **julgamento** que o ticket exige, não pelo tamanho do diff: uma mudança de uma linha num pipeline de deploy é Heavy, e um componente de 400 linhas que segue um padrão existente é Standard. Quando um ticket ficar entre dois níveis, escolha o mais alto. Se a maioria dos tickets de uma execução sair Heavy, as fatias provavelmente estão largas demais: revisite o passo 3.

### 5. Mostre o detalhamento

Apresente o detalhamento proposto como uma lista numerada. Para cada ticket, mostre:

- **Título**: nome curto e descritivo
- **Dificuldade**: o nível e o modelo sugerido
- **Bloqueado por**: quais outros tickets (se houver) precisam ser concluídos antes
- **O que entrega**: o comportamento de ponta a ponta que este ticket torna possível

**Não peça confirmação antes de publicar.** Publique logo depois de mostrar a lista: nada de pausa com "isto está bom?". Só pare e itere com o usuário antes se ele tiver pedido explicitamente, nesta execução, para revisar ou aprovar o detalhamento antes da publicação.

### 6. Publique os tickets

**Resolva onde publicar: não pergunte.** Escolha em silêncio:

1. Se o usuário pediu explicitamente, nesta execução, para publicar no GitHub, GitLab, markdown local ou outro tracker: use esse.
2. Senão, se `docs/agents/issue-tracker.md` existir (escrito pelo `/setup-skills`) e indicar um tracker: use esse.
3. Senão: **markdown local**. Não consulte `git remote`. Não apresente um seletor de destino.

Os tickets são os mesmos nos dois casos; só muda a forma das arestas de bloqueio:

- **Markdown local** → escreva um arquivo por ticket em `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`, numerado a partir de `01` na ordem de dependência (bloqueadores primeiro). A linha "Blocked by" de cada arquivo lista os números/títulos dos quais ele depende. Use o modelo de arquivo por ticket abaixo: um ticket por arquivo, nunca um arquivo único combinado.
- **Um issue tracker real (GitHub, GitLab, Linear, …)** → publique uma issue por ticket na ordem de dependência (bloqueadores primeiro), para que as arestas de bloqueio de cada ticket possam referenciar identificadores reais. Siga `docs/agents/issue-tracker.md`, quando existir. Use a relação nativa de bloqueio / sub-issue da plataforma quando ela tiver uma; caso contrário, coloque em "Blocked by" de cada ticket as issues que o bloqueiam. Se a origem foi uma issue existente, torne cada ticket sub-issue dela (a operação descrita no documento do tracker). Aplique o rótulo de triagem `ready-for-agent`, a menos que haja instrução em contrário: os tickets são pegáveis por agentes por construção.

Trabalhe a **fronteira**: qualquer ticket cujos bloqueadores estejam todos concluídos. Para uma cadeia puramente linear, isso significa de cima para baixo.

NÃO feche nem modifique nenhuma issue-pai.

<local-ticket-template>

```markdown
# <NN>: <Ticket title>

> **Difficulty:** Heavy | Standard | Light: **suggested model:** <model> (Claude Code) / <model> (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** the path of the spec this ticket comes from, relative to this ticket file (with the default layout, `../SPEC.md`). Omit the line only when no spec file exists (the plan came from the conversation).

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective, not a layer-by-layer implementation list.

**Seams:** the seams from the spec's Testing Decisions that this ticket exercises, one per bullet. If the ticket tests no seam (for example a pure config change), write "None" explicitly. Never leave the line out.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

Status: ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2
```

</local-ticket-template>

<issue-template>

> **Difficulty:** Heavy | Standard | Light: **suggested model:** <model> (Claude Code) / <model> (Cursor). Suggestion only, use whatever model you have to hand.

A linha de dificuldade é a primeira coisa no corpo da issue, acima de todas as seções.

## Parent

Uma referência à issue-pai no tracker (se a origem for uma issue existente; caso contrário, omita esta seção).

## What to build

O comportamento de ponta a ponta que este ticket torna possível, da perspectiva do usuário, e não uma implementação camada por camada.

## Seams

Os seams das Testing Decisions da especificação que este ticket exercita, um por item. Se o ticket não testar nenhum seam, escreva "None" explicitamente. Nunca omita a seção.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- Uma referência a cada ticket bloqueador, ou "None (can start immediately)". Omita esta seção quando os bloqueadores tiverem sido definidos como arestas nativas.

</issue-template>

Em qualquer uma das formas, evite caminhos de arquivo específicos ou trechos de código: eles ficam desatualizados rápido. Exceção: se um protótipo produziu um trecho que codifica uma decisão com mais precisão do que a prosa consegue (máquina de estados, reducer, schema, formato de tipo), inclua-o e observe brevemente que veio de um protótipo. Reduza ao essencial das partes ricas em decisão, não uma demo funcional; apenas os pontos importantes.
