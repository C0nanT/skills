```yaml
name: frontend-handoff
description: Transforme uma mudança de backend concluída em um handoff colável para a equipe de frontend, com o veredito primeiro: deve mudar, deveria mudar, ou nada.
argument-hint: "Qual mudança? (caminho da especificação, branch, PR ou uma descrição de uma linha)"
disable-model-invocation: true
```

Uma mudança de backend entra e o dev de frontend precisa de uma resposta antes de qualquer outra coisa: **eu preciso mexer no meu código?** Esta skill responde com um **veredito** e depois o sustenta com evidências de contrato, exemplos de payload e uma checklist, tudo em um único bloco que a pessoa pode colar em um ticket ou em um chat.

Leia a mudança antes de julgá-la. Um veredito inferido do nome do branch é o modo de falha que torna esta skill inútil.

Escreva o handoff no idioma em que o usuário está falando: isso inclui os cabeçalhos de seção, os cabeçalhos das colunas das tabelas e os rótulos como "Sim/Não", não só a prosa. O modelo abaixo está em inglês apenas como esqueleto estrutural; traduza todos os cabeçalhos e rótulos dele, não só o conteúdo preenchido. Mantenha código, rotas, nomes de campos, valores de enum e códigos HTTP literalmente na língua de origem.

## Escopo

Apenas contexto. O trabalho de frontend é uma tarefa separada: o bloco descreve o que o frontend precisa decidir, nunca remendos para isso. Nunca escreva código de frontend.

## Passos

### 1. Fixe a mudança

O handoff precisa das duas metades: a **intenção** (o que deveria ser entregue) e o **código** (o que foi de fato entregue). Espere uma sessão nova, sem memória da construção, e leia as duas coisas no repositório.

**Intenção.** Pegue o que o usuário passou: uma pasta de funcionalidade, um caminho de especificação, um branch, um PR, commits, arquivos alterados ou uma descrição em texto. Uma pasta de funcionalidade é a forma mais rica: leia o `SPEC.md` para a funcionalidade inteira, depois cada `tickets/NN-*.md`; o corpo dos tickets diz qual comportamento foi prometido, e os critérios de aceitação marcados dizem o que foi entregue. Se nada foi passado, faça **uma** pergunta nomeando essas formas e depois continue.

**Código.** Fixe um ponto de referência e faça o diff contra ele, do mesmo jeito que o `/review-axes`:

- trabalho commitado → `git diff <fixed-point>...HEAD` (três pontos) mais `git log <fixed-point>..HEAD --oneline`, onde o ponto fixo é o que o usuário nomeou, ou o merge-base com o branch padrão quando ele não nomeou nada
- trabalho não commitado → `git add -N .` para que os arquivos novos apareçam, depois `git diff` simples

Um diff vazio significa que você fixou o ponto errado: diga isso e pergunte, em vez de escrever um handoff só a partir dos tickets.

Depois, leia a fonte da verdade do próprio contrato: definições de rota, validação de requisição, serializadores de resposta e os testes de funcionalidade. Um teste que afirma o corpo de uma resposta tem precedência sobre qualquer prosa, inclusive a da especificação.

Pronto quando cada ticket estiver contabilizado contra o diff: o comportamento entregue de cada um rastreado até o código, e qualquer ticket que o diff não cubra nomeado no handoff como fora deste lote, em vez de ser assumido como entregue em silêncio.

### 2. Aprenda o envelope deste repositório

Os julgamentos de contrato só são tão bons quanto o seu modelo do formato da resposta. Leia o `GLOSSARY.md` e o `CLAUDE.md` para a linguagem de domínio do projeto, depois os serializadores/resources e um teste de funcionalidade que passe, para fixar:

- o envelope padrão de sucesso (chaves de encapsulamento, posicionamento de paginação/meta)
- onde mora o estado derivado (campos calculados a partir de outros sistemas ou agregados, e quais subobjetos carregam o próprio status)
- o envelope de erro e quais códigos HTTP o frontend é conhecido por tratar
- estados de domínio que parecem intercambiáveis mas não são (excluído logicamente vs. finalizado vs. cancelado)

Pronto quando você conseguir escrever o envelope de cabeça e nomear os campos de estado derivado que a mudança pode mexer.

### 3. Classifique o contrato

Para cada um destes itens, decida mudou / não mudou e guarde a evidência:

- rotas adicionadas, renomeadas, removidas
- campos adicionados, renomeados, removidos, com tipo alterado ou que passaram a aceitar nulo
- enums ou valores de status adicionados, removidos ou redefinidos
- códigos HTTP e mensagens de erro que o frontend trata
- apenas comportamento: mesmo caminho, mesmo formato, respostas diferentes em casos de borda

Pronto quando cada linha da tabela de contrato tiver um sim/não com o arquivo ou teste que prova isso.

### 4. Escolha o veredito

Exatamente um, escolhido pela condição mais forte que se verifica:

- **Deve mudar**: mudança de contrato que quebra, ou nova capacidade que o frontend precisa consumir para que exista para os usuários.
- **Deveria mudar**: contrato idêntico, mas o comportamento atual do frontend agora está errado ou desperdiçando recurso: lógica local que espelha regras do backend que mudaram, um **workaround** que o backend acabou de tornar desnecessário, uma tela que lê um estado não terminal como terminal, um cache que nunca revalida depois de uma mutação que altera o estado derivado.
- **Nada é necessário**: contrato idêntico e o comportamento atual do frontend continua correto.

Duas travas. Um novo comportamento sob um contrato inalterado fica limitado a **Deveria mudar**: se a especificação diz que não há mudança de contrato, schema ou enum, "Deve mudar" está errado. E a simetria com o backend não é motivo: uma mudança no frontend só se justifica por um comportamento visível ao usuário ou por um contrato que o frontend lê.

Pronto quando o veredito nomear a única condição que o decidiu.

### 5. Preencha o bloco

Preencha o modelo abaixo. Marque uma seção como `N/A` em vez de inflá-la: uma rota ou campo inventado é pior do que uma lacuna.

### 6. Salve o handoff

Se o veredito for **Nada é necessário**, pule o salvamento: sem arquivo, sem bloco do modelo. Responda no chat apenas com a linha do veredito e a frase única de motivo, e pare aí.

Caso contrário, salve o bloco preenchido em `.scratch/<feature-slug>/frontend-handoff.md`, criando o diretório se ele ainda não existir (veja `docs/agents/issue-tracker.md` para o layout de `.scratch/`). Derive `<feature-slug>` da pasta de funcionalidade fixada no passo 1 quando houver uma; caso contrário, transforme em slug o nome curto da funcionalidade do título do modelo. Se já existir um handoff nesse caminho, sobrescreva-o: ele descreve a mesma mudança, não uma nova. Salve sem pedir permissão antes.

### 7. Entregue

Verifique primeiro o host: `printenv CLAUDECODE` retorna `1` no Claude Code, vazio em outros lugares.

- **Claude Code**: o arquivo é a cópia, então não o reimprima. Responda apenas com a linha do veredito e o caminho salvo.
- **Em outros lugares**: linha do veredito, o bloco inteiro e depois o caminho salvo em uma linha.

## Modelo de saída

```markdown
## Frontend context: <short feature name>

### Verdict
**<Must change | Should change | Nothing required>**: <one sentence>.

### What the backend changed
- …

### API contract
| Item | Changed? | Detail |
|------|----------|--------|
| Routes | Yes/No | … |
| Envelope / fields | Yes/No | … |
| Enums / statuses | Yes/No | … |
| HTTP codes / known errors | Yes/No | … |

### New behaviour under the same contract
- Before: …
- Now: …

### Frontend impact
| Area | Change needed? | Action |
|------|----------------|--------|
| Types / envelope parsing | … | … |
| Screens & states (e.g. states treated as terminal) | … | … |
| Request payload construction (POST/PUT/PATCH) | … | … |
| Cache, lists, invalidation | … | … |
| 4xx handling | … | … |
| Flows out of scope | No | … |

### Payload / response examples
\`\`\`json
{ … }
\`\`\`

### What the frontend should stop assuming
- …

### Checklist
- [ ] …
```

## Catálogo de workarounds

Workarounds do frontend que uma mudança no backend costuma aposentar. Cada um, se a mudança removeu a causa, é um **Deveria mudar**: nomeie o workaround e a evidência de que ele não é mais necessário:

- reenviar histórico ou coleções inteiras que não mudaram para escapar de um erro de validação
- remover campos de um payload de atualização para passar pela validação
- uma tela congelada porque um estado apenas parece terminal
- recálculo no cliente de uma regra que o backend agora devolve
- um cache que serve estado derivado desatualizado depois de uma mutação
