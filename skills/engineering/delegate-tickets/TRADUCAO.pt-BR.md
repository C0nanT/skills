```yaml
name: delegate-tickets
description: Orquestra a implementação sequencial de tickets por meio de subagentes novos, exigindo que cada um use a skill /implement.
disable-model-invocation: true
```

# Delegar tickets

Delegue uma sequência ordenada de tickets a subagentes novos, um de cada vez. A sessão principal **apenas orquestra**: ela não implementa, testa, revisa, edita nem faz commit. Não duplique aqui o fluxo interno da skill `implement`.

## Entrada

Aceite um diretório de tickets ou uma lista explícita de arquivos de ticket, além do caminho do repositório (padrão: o diretório de trabalho atual). Confirme o caminho do repositório antes de começar: todo prompt de subagente precisa nomeá-lo explicitamente, já que o subagente pode não herdar o seu diretório de trabalho.

Preserve a ordem de uma lista explícita como foi dada. Para um diretório, monte a ordem você mesmo:

1. Leia cada arquivo de ticket e pegue a linha **Blocked by**.
2. Ordene os bloqueadores primeiro (topológico). Use o prefixo de nome de arquivo `NN-` apenas para desempatar tickets que não estão bloqueados entre si.
3. Se as arestas discordarem dos prefixos numéricos, ou se houver um ciclo, pare e mostre o conflito ao usuário. Não chute.

O usuário pode informar um ponto de partida ("comece pelo ticket 04"): comece ali e deixe os tickets anteriores em paz.

## Portão de dificuldade

Esta skill só roda trabalho de nível intermediário sem supervisão. Antes de começar, leia a linha `Difficulty:` de **todos** os tickets da sequência, não só do próximo, para que um ticket Heavy pare a execução antes de qualquer trabalho ser feito.

- **Standard** ou **Light**: roda.
- **Heavy**, ou **sem linha `Difficulty:`**: pare a sequência antes desse ticket e diga ao usuário que esse ticket precisa de Opus e de um humano por perto, então ele deve ser executado manualmente com `/implement`. Uma linha ausente é um bloqueio, nunca um nível padrão. Os tickets que vêm antes dele na ordem ainda podem rodar.

## Isolando o diff de cada ticket

`/implement` faz commit do seu trabalho no branch atual quando termina, então **cada ticket é um commit** e a árvore de trabalho não commitada é sempre exatamente o trabalho do ticket atual enquanto ele roda.

**Antes do primeiro ticket:**

1. Rode `git status --short` no repositório.
2. Se houver qualquer coisa pendente, mostre ao usuário e pare: ele faz commit ou stash antes, para que o commit do primeiro ticket carregue apenas o trabalho desse ticket.

## Fluxo de trabalho

Para cada ticket, na ordem:

1. **Pule se já estiver concluído**: se todo checkbox de critério de aceitação do arquivo do ticket já estiver `- [x]`, informe que ele já está completo e siga adiante.
2. Informe o progresso ao usuário: `Ticket <N>/<M>: <title>`.
3. Inicie **um subagente novo**, usando o mecanismo de subagentes do host: `Agent` no Claude Code, `Task` no Cursor, o equivalente em outros hosts. Use um subagente de propósito geral com acesso total às ferramentas, em **Sonnet** (ou o modelo intermediário equivalente do host) com **`effort: medium`**. Se o host não puder definir modelo ou esforço por criação, diga isso ao usuário e pare, em vez de criar o subagente com o que a sessão usa. Se o host não tiver nenhum mecanismo de subagentes, pare e diga ao usuário que esta skill não pode rodar ali.
4. Rode-o de forma **síncrona**, nunca em segundo plano, nunca em paralelo com outro ticket. O sequenciamento é o ponto central desta skill; cada commit só contém um ticket se exatamente um ticket estiver em andamento.
5. Espere terminar e então **verifique** antes de continuar: o subagente relatou sucesso claro e completo, o trabalho dele está commitado (`git status --short` limpo), **e** todo checkbox de critério de aceitação do arquivo do ticket agora está `- [x]` (o `/review-axes` os sincroniza a partir do código no fim do `/implement`). Um relatório de sucesso com critérios desmarcados é uma falha: o código não fez o que o ticket pedia.
6. Se passar, registre o commit do ticket (`git log -1 --oneline`) e comece o próximo.
7. Em qualquer falha, bloqueio, problema não resolvido, resultado incerto ou critério desmarcado: **pare imediatamente**. Deixe o trabalho daquele ticket como está (o commit dele, ou o que ele deixou sem commit), para que o usuário veja exatamente o que foi alterado. Não comece outro ticket. Relate o problema e espere instruções.

Use um subagente novo para cada ticket. Nunca reutilize a sessão de um ticket anterior.

## Prompt do subagente

```text
Implement `<ticket-path>` in `<repository-path>` using the `implement` skill.

When you invoke `/review-axes`, give it "the unstaged working tree" as its
fixed point, so it reviews only your ticket's changes, and give it
`<ticket-path>` as its spec argument, so it checks and ticks that ticket's
checkboxes.

Nobody is available to answer you. Any question you would ask the user (a
missing spec, an effort gate, an ambiguity) is a blocker: stop and report the
question. Never answer it yourself and never do that work inline.

Report clear success or describe any failure, blocker, unresolved issue, or
uncertainty. Include the hash of the commit `/implement` made.
```

## Relatório final

Quando todos os tickets tiverem sucesso, liste os tickets concluídos com as sessões de subagente e os commits de cada um.

Se a sequência parar, identifique o ticket que falhou, o problema dele e onde está o trabalho dele (o commit, ou a árvore de trabalho não commitada).
