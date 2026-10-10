# Issue tracker: markdown local

As issues e especificações deste repositório vivem como arquivos markdown em `.scratch/`.

## Convenções

- Uma funcionalidade por diretório: `.scratch/<feature-slug>/`
- A especificação é `.scratch/<feature-slug>/SPEC.md`
- Os tickets de implementação são `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`, numerados a partir de `01`
- O estado de triagem é registrado em uma linha `Status:` perto do topo de cada arquivo de ticket (veja `triage-labels.pt-BR.md` para as strings de papel)
- Comentários e o histórico de conversa são acrescentados ao final do arquivo, sob um título `## Comments`

## Quando uma skill diz "publicar no issue tracker"

Crie um arquivo novo em `.scratch/<feature-slug>/` (criando o diretório, se necessário).

## Quando uma skill diz "buscar o ticket relevante"

Leia o arquivo no caminho indicado. O usuário normalmente passa o caminho ou o número da issue diretamente.

## Operações de wayfinding

Usadas pelo `/wayfinder`. O **mapa** é um arquivo com um arquivo **filho** por ticket.

- **Mapa**: `.scratch/<effort>/map.md` (o corpo de Notes / Decisions-so-far / Fog).
- **Ticket filho**: `.scratch/<effort>/tickets/NN-<slug>.md`, numerado a partir de `01`, com a pergunta no corpo. Uma linha `Type:` registra o tipo do ticket (`research`/`prototype`/`grilling`/`task`); uma linha `Status:` registra `claimed`/`resolved`.
- **Bloqueio**: uma linha `Blocked by: NN, NN` perto do topo. Um ticket está desbloqueado quando todos os arquivos que ele lista estão `resolved`.
- **Fronteira**: percorra `.scratch/<effort>/tickets/` buscando arquivos abertos, desbloqueados e não reivindicados; vence o primeiro pelo número.
- **Reivindicar**: defina `Status: claimed` e salve antes de qualquer trabalho.
- **Resolver**: acrescente a resposta sob um título `## Answer`, defina `Status: resolved` e depois acrescente um ponteiro de contexto (resumo + link) às Decisions-so-far do mapa em `map.md`.

## Funcionalidades concluídas

Uma pasta de funcionalidade concluída é movida inteira para `docs/archive/<feature-slug>/` (veja `docs/archive/README.md`). Rode `/archive-feature` para chegar lá: ele define a especificação e os tickets como `done` e faz o `git mv`.
