# Limpeza da dívida técnica das Engineering skills

Status: ready-for-agent

Origem: mapa de dívida técnica de 2026-10-03 do módulo Engineering skills (as 10 linhas, com as decisões registradas na mesma data).

## Problem Statement

Como mantenedor deste fork, eu confio nas engineering skills para rodar o fluxo spec → tickets → implementação → revisão, e para configurar repos com `/setup-skills`. A revisão de 2026-10-03 mostrou que várias dessas skills quebram hoje, de formas silenciosas:

- O `/setup-skills` pode apagar o settings do projeto do usuário, e a lista de comandos git bloqueados tem um furo (`git -C`).
- O `/implement` não consegue chamar o `/tdd`, e o `/wayfinder` não consegue chamar o `/research`, porque o modo de invocação dessas skills diverge entre os três lugares onde está gravado.
- Quem escolhe o tracker local recomendado recebe um tracker doc sem as regras de wayfinding. O nome da spec também varia (`SPEC.md` contra `spec.md`).
- O `/delegate-tickets` roda tickets sem limite de modelo ou esforço, executa tickets pesados sem supervisão e, quando bate num ponto que exige resposta humana, segue fazendo o trabalho em vez de parar.
- O roteador `ask-skills` manda o usuário para caminhos e skills que não existem.
- Texto escrito por terceiros (MR, issue, página web) entra no shell e em sub-agentes sem nenhuma barreira.
- O `wizard` pode colocar segredos num arquivo que vai para o git.
- O histórico do `tech-debt-map` se perde quando o `.scratch/` é limpo.

Nada disso é pego pelo `validate.sh`, que só confere frontmatter, listas de README e plugin, e markdownlint.

## Solution

Corrigir as 10 linhas do mapa preservando o comportamento que já funciona. Em paralelo, ensinar o `validate.sh` a pegar as classes de erro que deixaram esses problemas passar, para que não voltem no próximo sync com upstream ou na próxima mudança de modo de uma skill.

Quando terminar:
- O `/setup-skills` nunca destrói um settings existente, sempre oferece o mapeamento de labels e instala um tracker local completo.
- Toda skill tem um único modo de invocação, coerente nos três lugares, e toda chamada entre skills aponta para algo alcançável.
- O `/delegate-tickets` só executa tickets Standard e Light em Sonnet com esforço médio, e para diante de ticket Heavy ou de qualquer pergunta sem humano para responder.
- O roteador diz a verdade.
- As skills que leem texto de terceiros tratam esse texto como dado.
- O histórico do `tech-debt-map` sobrevive no índice versionado.

## User Stories

### Guardrails do `/setup-skills` (linha 1)

1. Como usuário sem `jq` instalado, quero que o `/setup-skills` pare e me diga que precisa de `jq`, para que meu `.claude/settings.json` não seja substituído por `{}`.
2. Como usuário com um `settings.json` que tem um erro de sintaxe, quero que o setup pare e me mostre o erro, para que eu conserte o arquivo em vez de perder tudo em silêncio.
3. Como usuário com um `settings.json` válido, quero que o setup só acrescente as regras de deny e mantenha minhas allow rules, hooks e env.
4. Como usuário, quero uma cópia de segurança do settings antes de ele ser reescrito, para poder voltar atrás se algo der errado.
5. Como usuário sem `settings.json`, ou com um arquivo vazio, quero que o setup crie o arquivo com as regras de deny, como faz hoje.
6. Como usuário que roda o setup duas vezes, quero que a segunda execução não duplique regras.
7. Como mantenedor, quero que `git -C <dir> push` (e os equivalentes para commit, reset, clean e rebase) também fiquem bloqueados, para que o agente não contorne a lista de deny trocando o diretório.

### Tracker local (linha 2)

8. Como usuário que aceita o tracker local recomendado, quero que o tracker doc instalado traga a seção "Wayfinding operations", para que o `/wayfinder` saiba o formato do map, do claim, do bloqueio e da fronteira.
9. Como usuário rodando duas sessões de `/wayfinder`, quero uma regra de claim escrita, para que as duas não peguem o mesmo ticket.
10. Como usuário no Linux, quero que toda skill use `SPEC.md` como nome da spec, para que o `/frontend-handoff` encontre a spec que o `/to-spec` escreveu.
11. Como mantenedor, quero que o tracker doc deste repo use o mesmo nome de spec do template, para que o repo seja exemplo do que a skill instala.
12. Como mantenedor, quero que o template do tracker local esteja no ledger de divergências, para que o sync com upstream não o reverta para `issues/`.

### Modo de invocação (linha 3)

13. Como usuário do `/implement`, quero que ele consiga chamar o `/tdd`, para que o build seja feito em fatias red-green como a skill promete.
14. Como usuário do `/wayfinder`, quero que os tickets de pesquisa consigam chamar o `/research`, para que eles rodem em paralelo como está escrito.
15. Como usuário do `/delegate-tickets` no Codex, quero que os sub-agentes consigam chamar o `/implement`, para que a delegação funcione nos dois harnesses.
16. Como usuário do Codex, quero que o `/setup-skills` e o `/delegate-tickets` nunca sejam disparados sozinhos, porque um mexe no settings e o outro faz build sem supervisão.
17. Como leitor do README, quero ver cada skill no grupo certo (User-invoked ou Model-invoked), para saber se posso esperar que o modelo a chame.
18. Como leitor do README e do roteador, quero que a descrição do `/implement` diga que ele entrega uma mensagem de commit e nunca commita.
19. Como mantenedor, quero que toda divergência de modo em relação ao upstream esteja no ledger, para que o próximo sync não desfaça uma parte e mantenha outra.
20. Como mantenedor, quero que o `validate.sh` falhe quando o `SKILL.md` e o `openai.yaml` discordarem sobre o modo de uma skill.
21. Como mantenedor, quero que o `validate.sh` falhe quando uma skill não tiver `agents/openai.yaml`.
22. Como mantenedor, quero que o `validate.sh` falhe quando uma skill chamar pela Skill tool outra skill que é user-invoked.

### Texto de terceiros (linha 4)

23. Como revisor usando o `/review-mr`, quero que o nome do branch vindo da MR nunca seja colado sem aspas num comando de shell, para que um nome malicioso não execute nada na minha máquina.
24. Como revisor, quero que o `/review-mr` resolva o branch para um SHA quando possível, para revisar exatamente o commit que a MR aponta.
25. Como revisor, quero que o título e a descrição da MR cheguem ao sub-agente marcados como dado não confiável, para que instruções escritas ali não sejam seguidas.
26. Como usuário do `/review-axes` com tracker remoto, quero o mesmo tratamento para o corpo de issues buscadas no tracker.
27. Como usuário do `/research`, quero que o conteúdo de páginas web seja tratado como dado, nunca como instrução.
28. Como mantenedor, quero a mesma frase nessas três skills, para que o padrão seja fácil de copiar para skills de outros buckets depois.

### `/delegate-tickets` sem supervisão (linhas 5 e 10)

29. Como usuário do `/delegate-tickets`, quero que ele leia a linha `Difficulty:` de cada ticket antes de começar, para que tickets Heavy nunca rodem sem mim.
30. Como usuário, quero que, diante de um ticket Heavy, a sequência pare e me diga que aquele ticket precisa de Opus e de um humano por perto.
31. Como usuário, quero que tickets Standard e Light rodem num sub-agente Sonnet (ou equivalente no host) com `effort: medium`, para que o custo não cresça com o esforço da minha sessão.
32. Como usuário, quero que um ticket sem linha `Difficulty:` seja tratado como bloqueio e pare a sequência, para que a falta de classificação não vire execução sem limite.
33. Como usuário, quero que qualquer pergunta que um sub-agente precise me fazer (spawn em esforço alto, onde está a spec, etc.) pare o sub-agente e volte como bloqueio, nunca como trabalho feito inline.
34. Como usuário do `/implement` sem humano disponível, quero que o fallback do gate de esforço alto seja parar e perguntar, e não fazer o trabalho inline.
35. Como usuário do `/implement` numa sessão interativa, quero que o gate de esforço alto continue me perguntando como hoje.
36. Como usuário do `/delegate-tickets`, quero que o `/review-axes` receba explicitamente o caminho do ticket como spec, para que marque os checkboxes do ticket certo.
37. Como usuário, quero que o `/implement` passe ao `/review-axes` o caminho da spec ou do ticket que recebeu, para que a revisão não dependa da heurística de busca.
38. Como mantenedor, quero que o prompt do sub-agente do `/delegate-tickets` não repita passos que o `/review-axes` já faz, para que haja uma fonte só.

### Labels de triagem (linha 6)

39. Como usuário com labels de nome próprio no GitHub ou GitLab, quero que o `/setup-skills` sempre me pergunte se quero manter os labels padrão, para poder mapear os meus e evitar duplicados.
40. Como usuário com os labels padrão, quero aceitar com uma palavra ("manter os padrões").
41. Como usuário, quero que o `docs/agents/triage-labels.md` seja sempre gerado, porque `/to-spec`, `/to-tickets` e `/review-axes` apontam para ele.
42. Como usuário que revisa trabalho pronto, quero que `ready-for-human` signifique "precisa de um humano: revisar a tarefa, o código e se a feature funciona", para que o label diga a verdade depois que o `/review-axes` o aplica.
43. Como usuário, quero que os templates de GitHub e GitLab não falem de um passo de triagem que este fork não tem.
44. Como usuário que faz grep por `Status:`, quero que o `/to-tickets` escreva a linha sem negrito, igual às outras skills.
45. Como mantenedor, quero que a Seção B incondicional esteja no ledger, para que o upstream não traga o gate do `triage` de volta.

### Roteador (linha 7)

46. Como usuário seguindo o `ask-skills`, quero que ele diga que os tickets locais ficam em `tickets/`, para eu não criar pastas que nenhuma skill lê.
47. Como usuário, quero que o roteador diga que o `/implement` nunca commita.
48. Como usuário, quero que o roteador pare de me mandar para o `/diagnosing-bugs`, que não uso e que não vem no plugin.
49. Como mantenedor, quero que a nota sobre `diagnosing-bugs` no ledger saia junto, porque perde o objeto.
50. Como mantenedor, quero que o grep do ledger pegue o caminho `issues/` com qualquer placeholder, para que o sweep de sync encontre todas as reversões.
51. Como mantenedor, quero que o `validate.sh` falhe se `issues/`, `spec.md` minúsculo ou `/diagnosing-bugs` reaparecerem nas engineering skills ou no roteador.

### Histórico do `tech-debt-map` (linha 8)

52. Como mantenedor, quero que o status de cada achado (aberto ou resolvido, e o commit que resolveu) fique no índice versionado, para que uma limpeza do `.scratch/` não apague o histórico.
53. Como colega que clona o repo, quero ver o mesmo histórico de achados que o autor da revisão, sem depender dos arquivos dele em `.scratch/`.
54. Como usuário do `/tech-debt-map`, quero que a próxima revisão leia o status no índice quando o relatório anterior não existir, e o atualize ao final.
55. Como usuário, quero que os relatórios detalhados continuem em `.scratch/`, como material de trabalho.

### Segredos do `wizard` (linha 9)

56. Como usuário do `/wizard`, quero que ele cheque se o arquivo de env está no `.gitignore` antes de gravar o primeiro valor, para que meus segredos não vão parar no git.
57. Como usuário com `.env` fora do `.gitignore`, quero que o wizard peça confirmação ou ofereça incluir o arquivo no `.gitignore`.
58. Como usuário com `.env` já ignorado, quero que o wizard siga sem perguntar nada a mais.
59. Como usuário que gera um wizard, quero que a checagem estática do script gerado confira que o arquivo de env está ignorado.

### Documentação

60. Como leitor de `aihero.dev/skills-<nome>`, quero que as páginas de docs das skills cujo comportamento mudou reflitam o novo comportamento.
61. Como leitor dos guias em pt-br e en, quero que os guias afetados (setup-skills, implement, tdd, ask-skills) não contradigam as skills.

## Implementation Decisions

### Decisões já tomadas (revisão de 2026-10-03)

- `tdd` e `research` voltam a ser model-invoked. `implement` passa a ser model-invoked nos dois harnesses. `delegate-tickets` e `setup-skills` continuam user-invoked e ganham o arquivo de política do Codex.
- O nome canônico da spec no tracker local é `SPEC.md`.
- A Seção B (labels) do `/setup-skills` roda sempre, com "manter os padrões" como resposta recomendada.
- `ready-for-human` continua sendo o único label do fim da implementação. Muda só a definição: precisa de um humano para revisar tarefa, código e funcionamento da feature.
- `/delegate-tickets` só executa tickets de nível médio (Standard ou Light, Sonnet ou equivalente) com `effort: medium`. Ticket Heavy para a execução.
- Sem humano para responder, qualquer gate de pergunta faz o agente parar e reportar a pergunta. Nunca fazer inline.
- `/diagnosing-bugs` sai do roteador.
- A lista de deny cobre as variantes com `git -C <dir>`.
- O histórico de achados do `tech-debt-map` vive no índice versionado (`docs/tech-debt/README.md`, seção "Findings ledger", que já foi criada).

### Módulos alterados

- **`setup-skills`**: snippet de merge do settings (checagem de `jq`, semear `{}` só quando o arquivo não existe ou está vazio, parar em JSON inválido, backup antes de substituir, variantes `-C` nas duas cópias da lista de deny); Seção B incondicional; template do tracker local com a seção Wayfinding e `SPEC.md`; definição de `ready-for-human` no template de labels; remoção das frases sobre "o passo de triagem" nos templates de GitHub e GitLab; arquivo de política do Codex.
- **`implement`**: chamada ao `tdd` pela forma "Call the Skill tool with"; fallback do gate de esforço alto passa a ser parar e perguntar quando não há humano; passa ao `review-axes` o caminho da spec ou do ticket recebido; política do Codex removida.
- **`tdd`, `research`**: remoção do `disable-model-invocation`. O `research` ganha a frase de dado não confiável para conteúdo web.
- **`wayfinder`**: nenhuma mudança de texto; volta a funcionar porque o `research` fica alcançável.
- **`delegate-tickets`**: leitura da linha `Difficulty:` antes de cada ticket (Heavy ou ausente para a sequência); sub-agente em Sonnet ou equivalente com `effort: medium`; o prompt do sub-agente diz que qualquer pergunta vira bloqueio e passa o caminho do ticket como spec do `review-axes`; remoção do `git add -N .` duplicado; arquivo de política do Codex.
- **`review-mr`**: refs sempre entre aspas simples ou resolvidas para SHA; título e descrição da MR vão ao sub-agente num bloco marcado como dado não confiável.
- **`review-axes`**: corpo de issue remota marcado como dado não confiável. A heurística de busca de spec não muda.
- **`to-tickets`**: linha `Status:` sem negrito.
- **`frontend-handoff`**: lê `SPEC.md`.
- **`ask-skills`**: `tickets/` no lugar de `issues/`; "entrega a mensagem de commit e nunca commita" no lugar de "before committing"; remoção da entrada de `/diagnosing-bugs`; descrição deixa de dizer "user-invoked skills".
- **`wizard`**: a biblioteca do template checa se o arquivo de env está ignorado antes do primeiro `write_env` (confirmar ou oferecer incluir no `.gitignore`); a checagem estática do passo 4 inclui esse item.
- **`tech-debt-map`**: os passos 5 e 7 leem e atualizam o "Findings ledger" do índice. O formato do índice no passo 7 passa a incluir essa seção. O passo 5 usa o ledger quando o relatório anterior não existe.

### Fora do módulo, mas na mesma mudança

- README raiz e README do bucket: `implement`, `tdd` e `research` no grupo Model-invoked; descrição do `implement` sem "before committing".
- Tracker doc deste repo: `SPEC.md`.
- Ledger de divergências: modo das três skills que divergem do upstream (no mínimo `implement` model-invoked e `research` revertido, conferindo contra o upstream qual estado diverge); Seção B incondicional; template do tracker local na linha de `tickets/`; grep de `issues/` com qualquer placeholder; remoção da nota sobre `diagnosing-bugs`.
- `validate.sh`: novas seções (ver Testing Decisions).
- Páginas em `docs/engineering/` e guias em `docs/guides/` das skills cujo comportamento mudou, seguindo o guia de escrita de docs do repo.
- Sem mudança no `plugin.json`: o conjunto de skills promovidas não muda.

### Regras de escrita

- Sem em-dash em nenhum texto novo.
- Chamadas operativas entre skills usam "Call the Skill tool with".
- A frase de dado não confiável é a mesma nas três skills que leem texto de terceiros.

## Testing Decisions

Um bom teste aqui confere comportamento observável: o que acontece com o arquivo do usuário, ou se o repo respeita uma invariante. Não testa a redação de uma frase. O seam é um só: `scripts/validate.sh`, que já roda no CI a cada push e pull request.

Novas seções no `validate.sh`:

1. **Paridade de invocação**: para cada skill, `disable-model-invocation: true` no `SKILL.md` se e somente se o `openai.yaml` tiver `allow_implicit_invocation: false`.
2. **Arquivo de política presente**: toda skill tem `agents/openai.yaml`.
3. **Alvos alcançáveis**: todo nome em `Call the Skill tool with "<nome>"` aponta para uma skill existente e model-invoked.
4. **Strings proibidas**: falha se reaparecerem o caminho `.scratch/<...>/issues/` nas engineering skills, `spec.md` minúsculo como nome de spec, ou `/diagnosing-bugs` no `ask-skills`.
5. **Snippets de shell**: extrai o bloco de merge do `setup-skills` e roda num diretório temporário em três cenários:
   - sem `jq` no PATH: o snippet falha e o `settings.json` original fica byte a byte igual;
   - com `settings.json` inválido: falha e o arquivo fica intacto;
   - com `settings.json` válido contendo allow rules: as allow rules continuam, as deny rules (incluindo as `-C`) aparecem, e a segunda execução não duplica.

   Extrai também a biblioteca do `wizard` e confere que `write_env` não grava sem confirmação quando o arquivo de env não está no `.gitignore` de um repo git temporário.

Como marcar os blocos que o teste extrai (um marcador em comentário, ou o primeiro bloco `bash` depois de um título) é decisão de implementação. O marcador só precisa ser estável e não aparecer na leitura do agente como instrução extra.

Mudanças só de texto (linhas 4, 5, 6, 8 e 10) não têm teste automático. Onde houver uma string que prova a mudança (por exemplo a frase de dado não confiável, ou `effort: medium` no `delegate-tickets`), um grep no `validate.sh` pode exigir que ela exista. O resto se verifica por revisão com `/review-axes` contra esta spec.

Precedentes no repo: as seções 2, 6 e 7 do `validate.sh` (consistência entre disco, README e `plugin.json`) usam o mesmo padrão de `fail`/`pass` e são o modelo a seguir. O ticket `06-validate-test-suite.md` em `.scratch/pipeline-improvements/` trata de testes para o próprio `validate.sh` e pode ser reaproveitado.

Antes de dar por pronto, rodar `scripts/validate.sh` localmente e conferir que passa.

## Out of Scope

- Os dois achados que ficaram fora do corte do mapa: modo local do `review-mr` assumindo branches no `origin`, e regra de destino de publicação duplicada entre `to-spec` e `to-tickets`.
- Aplicar a frase de dado não confiável a skills de outros buckets (`in-progress/`, `misc/`). Fica como guardrail no índice, para as próximas revisões.
- Conflito de vocabulário Issue × Ticket entre `CONTEXT.md` e `CLAUDE.md`: está fora do módulo e é assunto da revisão do módulo Agent standards.
- Mudar a heurística de busca de spec do `review-axes`.
- Criar um label novo (`ready-for-review` ou similar): decidido que não.
- Migrar `docs/agents/triage-labels.md` em repos de usuários que já rodaram o setup. A mudança vale para novas execuções do `/setup-skills`.

## Further Notes

- Ordem sugerida, vinda do plano do mapa:
  1. Linha 1 e linha 3: são as duas 🔴, e o mapa pede que sejam corrigidas antes de qualquer feature nova neste módulo.
  2. Linhas 2 e 6 juntas: mexem nos templates do `setup-skills`.
  3. Linhas 7, 9 e 8.
  4. Linha 5 antes da 10, porque a 10 depende da regra "sem humano, para".
  5. Linha 4 por último: é a frase padrão que depois vale para os outros buckets.
- Ao terminar cada linha, marcar o item como resolvido (com o commit) no "Findings ledger" de `docs/tech-debt/README.md`.
- O `ask-skills` precisa ser relido no fim: as linhas 3, 5 e 7 mudam como as skills se encaixam no fluxo.
