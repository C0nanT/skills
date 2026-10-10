```yaml
name: tech-debt-map
description: Audite um módulo de uma base de código que cresceu de forma orgânica e produza um mapa ordenado das piores dívidas técnicas, mais um plano incremental de limpeza. Registra quando cada módulo foi revisado pela última vez, para que nada apodreça sem ser observado. Só diagnóstico, não altera código.
disable-model-invocation: true
```

# Mapa de dívida técnica

Produza um **mapa de dívida** para **um módulo**: uma lista ordenada e com evidências do que há de pior naquele módulo agora, e um plano para corrigi-lo uma fatia por vez.

Um módulo por execução, de propósito. Um mapa do projeto inteiro é um mapa que ninguém percorre, e uma refatoração que abrange tudo é uma refatoração que ninguém começa. O projeto é coberto ao longo do tempo, módulo por módulo, e um **índice de revisões** versionado lembra quando cada um foi observado pela última vez.

O mapa é um **diagnóstico, não uma refatoração**. Nenhum código muda durante esta skill. O que você entrega é um arquivo que o usuário percorre ao longo de semanas, e que roda de novo mais tarde para ver o que mudou.

Dois vizinhos para não atrapalhar: `/improve-codebase-architecture` caça uma classe de problema (módulos rasos) e termina em uma sessão de grilling sobre um único candidato; `/review-axes` julga um diff. Esta varre um módulo em todos os eixos e termina em um mapa escrito.

## Processo

### 1. Mapeie os módulos

Antes de qualquer revisão, o projeto precisa ser dividido em módulos. Alguns projetos já fizeram isso; muitos não.

Detecte nesta ordem, parando na primeira fonte que produzir uma partição real:

1. **Declarado**: manifestos de build e arquivos de projeto. Membros de workspace (`pnpm-workspace.yaml`, workspaces do `package.json`, Cargo, Go), árvores `apps/`, `packages/` e `services/`, `.csproj` dentro de uma solução, módulos Maven ou Gradle, apps do Django.
2. **Layout de código-fonte**: os diretórios de primeiro nível sob a raiz do código, quando carregam significado (`src/billing/`, `src/auth/`) em vez de apenas camadas técnicas.
3. **Domínio**: uma partição que você propõe a partir do vocabulário do `GLOSSARY.md` e dos nomes no código, ignorando em qual pasta o código está.

Leia o `GLOSSARY.md` (vocabulário de domínio), os ADRs e o `CLAUDE.md`/`AGENTS.md` (os padrões que o repositório já assumiu). Uma decisão registrada em um ADR está resolvida, não é um achado. Deixe de fora o que a equipe não é dona: código vendorizado, arquivos gerados, lockfiles, saída de build, migrações já aplicadas.

Cada módulo recebe um nome, um conjunto de globs de caminho e uma **origem**: `declared` ou `proposed`. Quando a origem for `proposed`, diga isso em voz alta: "este projeto não declara módulos, então a partição abaixo é minha; corrija se ela cortar no lugar errado." A fronteira de um módulo proposto é uma hipótese, não um fato sobre o repositório, e o usuário é o único que pode confirmá-la.

**Reconcilie com o índice.** Se `docs/tech-debt/README.md` existir, ele é a fonte da verdade da partição: guarda os nomes e os globs usados por todas as revisões anteriores. Detecte de novo mesmo assim e compare; depois:

- Um módulo no disco que não está no índice é **novo**: entra na lista como nunca revisado.
- Um módulo no índice cujos caminhos sumiram todos é **removido**: marque a linha como `removed <YYYY-MM-DD>` e mantenha-a. A linha é o registro de que aquela dívida saiu do projeto; apagá-la perde esse registro.
- Um módulo que parece **renomeado ou fundido** é o único caso sobre o qual você pergunta, porque só o usuário sabe se `billing` virou `payments` ou se são coisas diferentes. Chutar aqui descarta em silêncio o histórico do módulo.

**Pronto quando cada módulo tiver nome, conjunto de caminhos e origem, e o índice e o disco concordarem.**

### 2. Escolha um módulo

Mostre a lista e deixe o usuário escolher. Ordene por **quanto tempo faz desde a última revisão, multiplicado pelo quanto o módulo mudou desde então**: um módulo sem nenhuma alteração há um ano importa menos do que um revisado em março e que recebeu 200 commits desde então. Módulos nunca revisados vêm primeiro.

| Módulo | Caminhos | Última revisão | Commits desde então | Achados abertos |
| ------ | -------- | -------------- | ------------------- | --------------- |

Conte o churn com `git log --oneline --since=<data da última revisão> -- <os globs do módulo>`; para um módulo nunca revisado, conte os últimos seis meses. Mostre as duas colunas brutas para que o usuário possa discordar da sua ordenação usando os mesmos números que você usou.

Recomende a primeira linha em uma frase, com o motivo. Se o usuário disser "you pick", acolha sem perguntar de novo. Se ele nomear dois módulos, revise o primeiro e diga que o segundo fica para a próxima vez: **um módulo por execução**.

**Quando o módulo escolhido for grande demais**, diga isso, proponha uma subpartição e volte a este passo. Grande demais quer dizer que a varredura passaria por cima em vez de ler: o módulo é, na prática, a árvore de código inteira, ou carrega mais código do que quatro subagentes conseguem ler com atenção. Um mapa superficial de um módulo enorme é pior do que nenhum mapa, porque o índice passa a dizer que o módulo foi revisado e ninguém volta a olhar por meses.

**Pronto quando exatamente um módulo estiver escolhido e o usuário tiver visto quando ele foi revisado pela última vez.**

### 3. Varredura

Despache quatro subagentes em paralelo, um por grupo de eixos. Cada um lê [AXES.pt-BR.md](AXES.pt-BR.md) para as próprias seções e devolve apenas achados, sem correções:

| Subagente | Seções de AXES.md |
| --------- | ----------------- |
| Estrutura | Architecture, Maintainability |
| Código | Code, Testability |
| Regras de negócio | Business rules |
| Runtime | Performance, Security and robustness |

Cada subagente recebe o nome e os globs do módulo, e devolve **no máximo 5 achados, ordenados**, cada um trazendo:

- **Evidência**: `path/to/file.ts:120-160`, lida e citada, nunca inferida a partir de um nome de arquivo ou de um layout de diretórios.
- **Custo**: a coisa concreta que fica mais difícil ou mais arriscada por causa disso. Um achado sem custo é uma preferência de estilo, e preferências de estilo ficam fora do mapa.
- **Raio de impacto**: o que mais precisa se mover quando isso se mover.

**Leia as bordas do módulo, não só o interior.** Metade do que importa (acoplamento, ciclos, uma regra espalhada por camadas, "uma mudança de uma linha toca cinco arquivos") só existe *entre* módulos, então chamadores e chamados entram no escopo como evidência. O que não entra no escopo é culpar um vizinho: um achado só ganha uma linha quando a evidência está em um arquivo que o módulo possui. Arquivos fora do módulo podem, e normalmente devem, ser citados na descrição.

**Pronto quando cada achado citar um intervalo de linhas que o agente de fato leu, dentro dos caminhos do módulo.**

### 4. Pergunte o que só a equipe sabe

Antes de escrever qualquer coisa, apresente os achados `needs-validation` ao usuário em **uma rodada em lote**: numerados, uma pergunta curta cada, com a sua melhor suposição anexada. Depois, espere. Uma rodada, não uma entrevista: esta skill termina em um arquivo, não em uma conversa.

- Uma resposta vira uma **decisão registrada** no mapa (a pergunta, a resposta, a data). O achado então ou entra na tabela ordenada, ou é descartado como regra intencional, e a decisão diz qual dos dois.
- **"Não sei" mantém o achado fora da tabela.** Ele continua `needs-validation`, carregando a pergunta exata e quem pode respondê-la. Um achado esperando uma resposta que ninguém tem é uma pergunta em aberto, não uma dívida priorizável, e misturar as duas coisas é como um mapa vira uma lista que a equipe aprende a ignorar. A próxima revisão encontra a pergunta de novo e pergunta outra vez.

**Pronto quando nenhum achado estiver ao mesmo tempo sem resposta e ranqueado.**

### 5. Escreva o mapa

Leia primeiro o mapa mais recente existente para **este módulo**: um achado já corrigido é marcado como **resolved** com o commit que o corrigiu, em vez de ser descartado, para que relatórios consecutivos mostrem o que se mexeu.

**Quando não há relatório anterior** (`.scratch/` foi apagado, ou é um clone novo), leia em vez disso o **Findings ledger** do módulo em `docs/tech-debt/README.md`. Reconfira cada linha do ledger marcada como `open` contra o código atual, e marque como resolved as que sumiram, encontrando o commit com `git log` nos caminhos citados. Linhas já resolvidas permanecem como estão. Um módulo sem relatório nem ledger é uma primeira revisão: não há nada para comparar.

Junte os quatro relatórios, descartando duplicatas e qualquer coisa cujo custo você não consiga declarar. Limite o mapa a **10 achados**: uma lista de todas as coisinhas é uma lista que ninguém executa. Achados que ficarem de fora do corte vão em uma única linha de fechamento, contados, não enumerados.

Escreva em `.scratch/tech-debt-map/<module-slug>/<YYYY-MM-DD>.md`, um arquivo novo por revisão, para que duas datas possam ser lidas lado a lado:

1. **Escopo**: o módulo, seus globs, sua origem (`declared` ou `proposed`) e o que ficou de fora de propósito.
2. **A tabela**, ordenada por retorno em relação ao raio de impacto, com empates resolvidos a favor do que bloqueia o trabalho que a equipe está prestes a fazer:

   | # | Achado | Localização | Eixo | Gravidade | Raio de impacto | Retorno |
   | - | ------ | ----------- | ---- | --------- | --------------- | ------- |
   | 1 | ... | `src/orders/handler.ts:88` | Business rules | 🔴 Critical | Contained | High |

   As rubricas das três classificações estão em [AXES.pt-BR.md](AXES.pt-BR.md#rubrics).
3. **Um bloco de detalhe por linha**, na ordem da tabela, com o número como título: **Problem** (o que existe agora), **Why it hurts** (o custo, com o exemplo que o mostra), **Evidence** (intervalos de linhas e uma citação curta quando o código deixa o ponto mais claro que a prosa), **Strategy** (a menor mudança que elimina a dor).
4. **Open questions**: os achados que continuam `needs-validation`, cada um com a pergunta e a quem perguntar.
5. **Decisions recorded**: o que o passo 4 respondeu e o que ficou resolvido com isso.

A tabela é a única fonte da verdade para as classificações; os blocos de detalhe nunca repetem as classificações.

**Pronto quando cada linha tiver um bloco de detalhe e cada bloco de detalhe tiver uma estratégia que preserve o comportamento atual.**

### 6. Planeje a limpeza

Feche o arquivo com um plano por fases para este módulo. Cada fase lista **apenas números de linha**, mais uma frase sobre a ordem dentro dela:

- **Fase 1, contida**: retorno alto, raio de impacto Contained. Seguro para entregar esta semana.
- **Fase 2, complexidade**: refatorações que tornam legível o pior código, um seam por vez.
- **Fase 3, estrutura**: as linhas que precisam de uma decisão de design antes. Marque as Systemic: elas se estendem além deste módulo e não são só deste módulo para agendar sozinho.

Depois, uma linha nomeando as linhas a limpar **antes que a próxima funcionalidade entre neste módulo**, e por quê. Esta linha é onde um Critical com raio Systemic volta: a ordenação o empurra para baixo na tabela, e ele não pode desaparecer por causa disso.

**Garantias não pertencem às fases.** Uma regra de lint, uma checagem ou uma prática que impede um achado de voltar é uma propriedade do projeto, não de um módulo só, então vai para o índice (passo 7), onde sobrevive e não é reescrita de quatro jeitos diferentes por quatro revisões de módulo.

### 7. Registre e passe adiante

Atualize o índice de revisões em `docs/tech-debt/README.md`, criando-o se ele não existir:

| Módulo | Caminhos | Origem | Última revisão | Relatório | Abertos |
| ------ | -------- | ------ | -------------- | --------- | ------- |
| Billing | `src/billing/**`, `src/invoices/**` | proposed | 2026-09-19 | `.scratch/tech-debt-map/billing/2026-09-19.md` | 7 |

O índice é commitado de propósito: os relatórios são material de trabalho e ficam em `.scratch/`, normalmente no gitignore, mas "ninguém olha para billing há oito meses" é algo que uma equipe precisa ver na revisão.

Abaixo da tabela, mantenha o **Findings ledger**: uma subtabela por módulo, para que o histórico de cada achado sobreviva a uma limpeza de `.scratch/` e a um clone novo. Os relatórios continuam em `.scratch/`; só este resumo é commitado.

```md
### Billing

| # | Finding | First seen | Status |
| - | ------- | ---------- | ------ |
| 1 | Discount rule duplicated in four handlers | 2026-09-19 | resolved (a1b2c3d) |
| 2 | Invoice totals recomputed per line item | 2026-09-19 | open |
```

Uma linha por achado, uma linha cada (o detalhe fica no relatório). `Status` é `open`, ou `resolved (<commit>)` com o commit que o corrigiu. Ao fim de cada revisão, atualize o ledger do módulo: acrescente os novos achados como `open` com a data de hoje, defina o status dos que o passo 5 encontrou corrigidos, e mantenha as linhas resolvidas. A coluna `Open` da tabela acima conta as linhas `open` do ledger.

Abaixo do ledger, mantenha a seção **Guardrails**, acrescida a cada execução, nunca reescrita: acrescente o que esta revisão aprendeu, pule o que já está lá.

**Diga antes de escrever pela primeira vez.** Esta skill se anuncia como uma skill que não altera nada, e `docs/tech-debt/README.md` é um arquivo versionado, então a primeira execução avisa o usuário de que vai criá-lo, em uma linha. Execuções seguintes atualizam sem perguntar.

Depois, diga ao usuário o caminho do relatório e as três primeiras linhas, e ofereça, sem fazer:

- `/to-spec` sobre as linhas que valem a pena agir, para decidir o que de fato muda, depois `/to-tickets` para dividir isso em trabalho rastreado. O mapa é um diagnóstico, então alguma coisa precisa decidir o tratamento antes de ser fatiada.
- `/improve-codebase-architecture` sobre qualquer linha com raio de impacto Systemic, onde a decisão de design vem antes até da especificação.

## Regras

- **Relate o que o código faz agora.** Leia o código antes de afirmar qualquer coisa sobre ele; um problema plausível que não existe custa mais ao usuário do que um problema perdido.
- **Todo achado nomeia o seu custo.** "Isto não é o padrão usual" não é custo. "Mudar a regra de desconto significa editar quatro arquivos, e o quinto foi esquecido da última vez" é.
- **Um achado que parece estranho mas pode ser deliberado é marcado como `needs-validation`**, e o passo 4 pergunta sobre ele. Regras de negócio são o caso típico: uma lógica de aparência estranha costuma ser um requisito real que ninguém escreveu.
- **As estratégias preservam o comportamento** e são incrementais: algo que uma pessoa consegue fazer em uma sentada, sem congelar nada. Quando um achado realmente exigir uma reescrita, diga isso e diga o que ela compra.
- **A partição é um contrato.** Depois que o nome e os globs de um módulo estiverem no índice, toda revisão posterior é medida contra eles. Corte com cuidado na primeira vez, e quando um corte se revelar errado, renomeie-o pelo passo 1 em vez de traçar discretamente uma nova linha.
- Respeite as convenções e as restrições existentes do repositório, inclusive as que você teria escolhido de outro jeito.
