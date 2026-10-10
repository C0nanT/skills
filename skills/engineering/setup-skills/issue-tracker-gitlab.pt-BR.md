# Issue tracker: GitLab

As issues e especificações deste repositório vivem como issues do GitLab. Use a CLI [`glab`](https://gitlab.com/gitlab-org/cli) para todas as operações.

## Convenções

- **Criar uma issue**: `glab issue create --title "..." --description "..."`. Use um heredoc para descrições de várias linhas. Passe `--description -` para abrir um editor.
- **Ler uma issue**: `glab issue view <number> --comments`. Use `-F json` para saída legível por máquina.
- **Listar issues**: `glab issue list -O json`, com os filtros `--label` adequados.
- **Comentar em uma issue**: `glab issue note <number> --message "..."`. O GitLab chama os comentários de "notes".
- **Aplicar / remover rótulos**: `glab issue update <number> --label "..."` / `--unlabel "..."`. Vários rótulos podem ser separados por vírgula ou informados repetindo a flag.
- **Fechar**: `glab issue close <number>`. `glab issue close` não aceita um comentário de fechamento, então publique a explicação antes com `glab issue note <number> --message "..."`, depois feche.
- **Merge requests**: o GitLab chama PRs de "merge requests". Use `glab mr create`, `glab mr view`, `glab mr note` etc., no mesmo formato de `gh pr ...`, trocando `pr` por `mr` e `comment`/`--body` por `note`/`--message`.

Infira o repositório a partir de `git remote -v`; o `glab` faz isso automaticamente quando é executado dentro de um clone.

## Merge requests como superfície de triagem

**MRs como superfície de pedidos: não.** _(Defina como `yes` se este repositório trata merge requests externos como pedidos de funcionalidade; as skills que triam pedidos recebidos leem esta flag.)_

Quando definida como `yes`, os MRs passam pelos mesmos rótulos e estados das issues, usando os equivalentes de `glab mr`:

- **Ler um MR**: `glab mr view <number> --comments` e `glab mr diff <number>` para o diff.
- **Listar MRs externos para triagem**: `glab mr list -F json`, depois mantenha apenas os MRs cujo autor não seja membro/dono do projeto (o MR de um contribuidor, e não o trabalho em andamento de um mantenedor).
- **Comentar / rotular / fechar**: `glab mr note`, `glab mr update --label`/`--unlabel`, `glab mr close`.

Diferente do GitHub, o GitLab numera issues e MRs separadamente, então `#42` não é ambíguo depois que você sabe qual superfície o mantenedor quer dizer.

## Quando uma skill diz "publicar no issue tracker"

Crie uma issue do GitLab.

## Quando uma skill diz "buscar o ticket relevante"

Execute `glab issue view <number> --comments`.

## Operações de wayfinding

Usadas pelo `/wayfinder`. O **mapa** é uma única issue com issues **filhas** como tickets.

- **Mapa**: uma única issue com o rótulo `wayfinder:map`, contendo o corpo de Notes / Decisions-so-far / Fog. `glab issue create --label wayfinder:map`. (Em planos do GitLab com epics nativos, um epic pode guardar o mapa no lugar; uma issue rotulada funciona em qualquer plano.)
- **Ticket filho**: uma issue com `Part of #<map>` no topo da descrição e os rótulos `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Uma vez reivindicado, o ticket é atribuído ao dev que conduz o mapa.
- **Bloqueio**: o **link de bloqueio nativo** do GitLab, a representação canônica e visível na interface. Adicione-o com a ação rápida `/blocked_by #<n>`, publicada como nota (`glab issue note <child> --message "/blocked_by #<blocker>"`). Links de bloqueio nativos são um recurso dos planos Premium/Ultimate; no plano gratuito (ou onde não estiverem disponíveis), recorra a uma linha `Blocked by: #<n>, #<n>` no topo da descrição. Um ticket está desbloqueado quando todos os bloqueadores estão fechados.
- **Consulta da fronteira**: `glab issue list -O json` restrito aos filhos do mapa, descartando qualquer um com bloqueador aberto: um link nativo `blocked_by` para uma issue aberta (`glab api projects/:id/issues/<child-iid>/links`), ou uma issue aberta na linha `Blocked by`, ou com responsável; vence o primeiro na ordem do mapa.
- **Reivindicar**: `glab issue update <n> --assignee @me`, a primeira escrita da sessão.
- **Resolver**: `glab issue note <n> --message "<answer>"`, depois `glab issue close <n>`, depois acrescente um ponteiro de contexto (resumo + link) às Decisions-so-far do mapa.
