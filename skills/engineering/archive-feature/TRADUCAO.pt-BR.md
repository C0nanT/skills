```yaml
name: archive-feature
description: Feche funcionalidades concluídas (especificação e tickets marcados como concluídos) e mova cada uma inteira de .scratch/ para docs/archive/, uma indicada ou todas de uma vez.
disable-model-invocation: true
```

# Arquivar funcionalidade

Feche funcionalidades concluídas e tire-as de `.scratch/`, para que sobrevivam à limpeza periódica. Trabalha apenas a partir dos arquivos. Nunca marca um checkbox, nunca edita o conteúdo de um ticket além da linha `Status:`.

## Entrada

Opcional. Pode ser uma funcionalidade, como nome de pasta (`.scratch/<feature-slug>/`) ou caminho para o `SPEC.md` dela (resolva os dois para a pasta da funcionalidade), ou nada.

- **Uma funcionalidade**: se a pasta não tiver `SPEC.md`, ela não é uma funcionalidade: diga isso e pare. Caso contrário, execute os passos 1 a 7 para ela.
- **Sem argumento**: execute a [execução sem argumento](#execução-sem-argumento) depois do passo 1. Não pergunte qual funcionalidade arquivar.

## 1. Checar o tracker

Se `docs/agents/issue-tracker.md` existir e indicar um tracker diferente de markdown local (GitHub, GitLab, Linear, ...), diga que esta skill não se aplica a um tracker remoto e pare. Não toque em nada.

## 2. Verificar a prontidão

Leia a especificação e cada arquivo em `.scratch/<feature-slug>/tickets/`.

- **Com tickets**: a funcionalidade está pronta somente quando o `Status:` de cada ticket é `ready-for-human` ou `done` **e** cada checkbox de cada ticket está marcado (`- [x]`). O status da própria especificação é ignorado: ele nunca se move no fluxo atual. Para cada ticket que falhar, registre o que falta: o status dele e cada caixa desmarcada.
- **Sem tickets**: os arquivos não permitem saber. Pergunte ao usuário se a funcionalidade foi implementada. Sim conta como pronta, não conta como incompleta.

## 3. Decidir

- **Pronta**: continue.
- **Incompleta**: mostre o que falta (tickets com o status errado, caixas desmarcadas) e pergunte ao usuário se ele prefere parar ou arquivar mesmo assim. Parar encerra a execução sem nenhuma alteração.

## 4. Verificar o destino

Se `docs/archive/<feature-slug>/` já existir, pare com um aviso. Nunca sobrescreva nem faça merge. Nada foi alterado até este ponto.

## 5. Fechar

Defina as linhas de status. `Status:` é a linha perto do topo da especificação e de cada ticket; substitua apenas o valor dela, nunca mais nada.

- Funcionalidade pronta: `Status: done` na especificação e em todos os tickets.
- Funcionalidade incompleta arquivada mesmo assim: `Status: done` na especificação e **somente** nos tickets que atenderam à regra de prontidão. Os tickets que não atenderam mantêm o status atual. Acrescente uma entrada `## Comments` no fim da especificação (crie o título se ele não existir), datada de hoje, listando cada ticket e cada item desmarcado que ficou de fora. Para uma funcionalidade sem tickets, a entrada diz que o usuário confirmou que ela não foi totalmente implementada.

Nunca marque nem desmarque um checkbox, em nenhum caso.

## 6. Mover

1. Se `docs/archive/` não existir, crie-a. Se `docs/archive/README.md` não existir, crie-o com exatamente este conteúdo:

   ```markdown
   # Archive

   Finished features moved out of `.scratch/` for later review: post-deploy checklists, frontend handoffs, specs and tickets worth keeping in the repo.

   - One feature per directory: `docs/archive/<feature-slug>/`, same layout it had in `.scratch/` (`SPEC.md`, `tickets/`, `POST-DEPLOY.md`, handoffs…).
   - Moved by the maintainer, as-is. Not a triage surface: nothing here is active work.
   ```

2. Execute `git mv .scratch/<feature-slug> docs/archive/<feature-slug>`. A pasta inteira é movida, com o layout intacto. Se a pasta não estiver versionada, o `git mv` falha: informe isso e pare, em vez de recorrer ao `mv`. Em uma execução sem argumento, isso pula essa funcionalidade e a execução segue.

## Execução sem argumento

Os passos 2 a 6 acima são os mesmos usados em uma execução de funcionalidade única, aplicados a cada funcionalidade.

- **Varredura.** Liste cada pasta diretamente abaixo de `.scratch/`. Uma pasta com `SPEC.md` é uma funcionalidade. Uma pasta sem ele aparece como `ignored (no SPEC.md)` e fica onde está. Pastas já arquivadas não estão aqui: elas saíram de `.scratch/`. Se não houver funcionalidades, diga isso e pare.
- **Verificar a prontidão** de cada funcionalidade com o passo 2. Uma funcionalidade sem tickets não pode ser julgada pelos arquivos: marque-a como `no tickets, will ask`.
- **Mostre uma única tabela-resumo**, com uma linha por funcionalidade: a funcionalidade, depois `ready`, ou o que falta (cada ticket com o status errado, cada caixa desmarcada), ou `no tickets, will ask`. Acrescente as pastas ignoradas. Marque uma funcionalidade cujo `docs/archive/<feature-slug>/` já exista como `destination exists, will be skipped`, independentemente da prontidão.
- **Resolva as funcionalidades sem tickets.** Pergunte, para cada uma, se ela foi implementada. Sim a move para o conjunto de prontas; não a move para o conjunto de incompletas.
- **Confirme uma vez.** Peça uma única confirmação para arquivar todas as funcionalidades prontas, citando-as pelo nome. Se o usuário recusar, nenhuma é arquivada.
- **Funcionalidades incompletas** são arquivadas somente quando o usuário as nomeia. Ofereça a escolha uma vez, depois da tabela, listando as funcionalidades incompletas. Nomear uma delas é a decisão de "arquivar mesmo assim", então não pergunte de novo: mostre a lista do que falta no relatório e execute o ramo de incompleta do passo 5 para ela. Uma que não for nomeada fica intocada.
- **Arquive cada funcionalidade escolhida**, uma por vez, nesta ordem: primeiro o passo 4 (verificação do destino), depois o passo 5, depois o passo 6. Uma colisão pula aquela funcionalidade com um aviso antes que qualquer coisa seja editada, e a execução continua com as demais. Não pare a execução por causa de uma falha de uma funcionalidade: registre-a e siga em frente.
- **Relatório.** Depois, execute o passo 7 com os resultados da execução inteira.

## 7. Relatório

Termine com um relatório. Para uma execução sem argumento, uma entrada por funcionalidade, mais as pastas ignoradas. Por funcionalidade: a funcionalidade arquivada e o novo caminho dela, quais tickets foram marcados como `done`, quais foram mantidos como estavam e por quê, e se uma nota `## Comments` foi adicionada. Se uma funcionalidade ou a execução parou (tracker remoto, destino existente, usuário optou por parar ou deixou de fora, sem especificação, `git mv` falhou), diga o motivo. Lembre o usuário de que os arquivos movidos e editados estão staged ou modificados, mas não commitados.
