# Issue tracker: GitHub

As issues e especificações deste repositório vivem como issues do GitHub. Use a CLI `gh` para todas as operações.

## Convenções

- **Criar uma issue**: `gh issue create --title "..." --body "..."`. Use um heredoc para corpos de várias linhas.
- **Ler uma issue**: `gh issue view <number> --json number,title,body,labels,comments`.
- **Listar issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, com os filtros `--label` e `--state` adequados.
- **Tornar uma issue sub-issue de um pai**: `gh issue create --parent <parent> ...`, ou `gh issue edit <parent> --add-sub-issue <child>` depois (`gh` 2.94+). `gh` mais antigo: `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>` (id do banco, como em **Blocking** abaixo). Sem sub-issues, coloque `Part of #<parent>` no topo do corpo da filha.
- **Comentar em uma issue**: `gh issue comment <number> --body "..."`
- **Aplicar / remover rótulos**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Fechar**: `gh issue close <number> --comment "..."`

Infira o repositório a partir de `git remote -v`; o `gh` faz isso automaticamente quando é executado dentro de um clone.

## Pull requests como superfície de triagem

**PRs como superfície de pedidos: não.** _(Defina como `yes` se este repositório trata PRs externos como pedidos de funcionalidade; as skills que triam pedidos recebidos leem esta flag.)_

Quando definida como `yes`, os PRs passam pelos mesmos rótulos e estados das issues, usando os equivalentes de `gh pr`:

- **Ler um PR**: `gh pr view <number> --comments` e `gh pr diff <number>` para o diff.
- **Listar PRs externos para triagem**: `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`.
- **Comentar / rotular / fechar**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

O GitHub compartilha um único espaço de números entre issues e PRs, então um `#42` nu pode ser qualquer um dos dois: resolva com `gh pr view 42` e recorra a `gh issue view 42` se for preciso.

## Quando uma skill diz "publicar no issue tracker"

Crie uma issue do GitHub.

## Quando uma skill diz "buscar o ticket relevante"

Leia como em **Ler uma issue** acima.

## Operações de wayfinding

Usadas pelo `/wayfinder`. O **mapa** é uma única issue com issues **filhas** como tickets.

- **Mapa**: uma única issue com o rótulo `wayfinder:map`, contendo o corpo de Notes / Decisions-so-far / Fog. `gh issue create --label wayfinder:map`.
- **Ticket filho**: uma issue vinculada ao mapa como sub-issue do GitHub (veja **Tornar uma issue sub-issue de um pai**). Onde sub-issues não estiverem habilitadas, adicione a filha a uma lista de tarefas no corpo do mapa e coloque `Part of #<map>` no topo do corpo da filha. Rótulos: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Uma vez reivindicado, o ticket é atribuído ao dev que conduz o mapa.
- **Bloqueio**: as **dependências nativas de issues** do GitHub, a representação canônica e visível na interface. Adicione uma aresta com `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, em que `<blocker-db-id>` é o **id numérico do banco** do bloqueador (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _não_ o `#number` nem o `node_id`). O GitHub informa `issue_dependencies_summary.blocked_by` (somente bloqueadores abertos, a trava viva). Onde dependências não estiverem disponíveis, recorra a uma linha `Blocked by: #<n>, #<n>` no topo do corpo da filha. Um ticket está desbloqueado quando todos os bloqueadores estão fechados.
- **Consulta da fronteira**: liste os filhos abertos do mapa (`gh issue list --state open`, restrito às sub-issues / lista de tarefas do mapa), descarte qualquer um com bloqueador aberto (`issue_dependencies_summary.blocked_by > 0`, ou uma issue aberta na linha `Blocked by`) ou com responsável; vence o primeiro na ordem do mapa.
- **Reivindicar**: `gh issue edit <n> --add-assignee @me`, a primeira escrita da sessão.
- **Resolver**: `gh issue comment <n> --body "<answer>"`, depois `gh issue close <n>`, depois acrescente um ponteiro de contexto (resumo + link) às Decisions-so-far do mapa.
