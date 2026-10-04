# Skill flow improvements: backlog

Pontos levantados na análise do fluxo grill-me → to-spec → to-tickets → implement (tdd + review-axes), em 2026-10-03.
Cada item vira insumo para `/to-spec` depois de decidido.

Status: 🧭 em decisão · 📋 decidido, aguardando spec · 📝 spec escrito · ✅ feito · ⏳ depois

## Furos no fluxo

### 1. Ninguém refatora ✅ feito (SPEC.md)
- **Decidido:** passo novo **Refactor** no `implement`, entre Test e Review: uma passada sobre o diff, só com a suíte verde, sem mudar comportamento, rodando a suíte de novo no fim. `tdd` fica como no upstream. Divergência registrada só para o `implement`.
- **Decidido (escopo):** o refactor mexe só no código que o diff criou ou alterou. Algo que valha a pena fora do diff vira 🟡 no Verdict, com sugestão de ticket de prefactor.
- **Decidido (falha):** antes de começar, grava um snapshot sem commit (`git stash create` ou cópia dos arquivos do diff). Se a suíte ficar vermelha depois do refactor, desfaz o refactor inteiro, segue para o Review com o código verde anterior e registra 🟡 no Verdict.
- `tdd` tira o refactor do loop ("belongs to the review stage"), `review-axes` só reporta, `implement` só faz o Verdict. Resultado: código verde e nunca limpo.
- Origem: upstream (commit `80e9dcc`, upstream aponta para `code-review`). Mudar aqui é divergência nova: registrar em `.agents/fork-divergences.md`.
- Opções: (a) refactor de volta no `tdd` com limite (só no verde, sem mudar comportamento); (b) passo de correção no `implement` após o review (ver item 4).

### 2. Seams confirmadas 2 a 3 vezes ✅ feito (SPEC.md)
- **Decidido:** `to-tickets` preenche `Seams:` em cada ticket a partir do spec; `tdd` usa o ticket, ou o spec quando não houver ticket, e só pergunta se precisar de uma seam fora da lista. `to-spec` pergunta sobre as seams uma vez, dentro do lote único, já com proposta; sem outras dúvidas, faz uma pergunta curta só sobre elas.
- `to-spec` passo 3 pergunta ao usuário (e contradiz a regra de perguntar em um lote único).
- `tdd` exige confirmar de novo antes de cada teste, inclusive dentro do `implement`, ticket a ticket.
- Ideia: `to-spec` inclui as seams no lote único; `tdd` aceita como acordadas as seams de **Testing Decisions** do spec ou de um campo `Seams:` no ticket.

### 3. Ticket local não aponta para o spec ✅ feito (SPEC.md)
- **Decidido:** linha `**Spec:** ../SPEC.md` no template local (caminho relativo ao ticket). Ordem de busca do `review-axes`: argumento passado → campo `Spec:` do ticket → `Parent` (tracker remoto) → heurística atual. `implement` passa o caminho do ticket ou do spec explicitamente ao `review-axes`. Resolve o finding #10.
- O template de ticket local do `to-tickets` não tem campo de origem; `review-axes` adivinha pelo nome do branch ou da feature.
- Mesmo problema do finding #10 em `docs/tech-debt/README.md`.
- Ideia: `**Spec:** ../SPEC.md` no template; `review-axes` lê o campo antes da heurística.

### 4. Review não leva a nenhuma ação ⏳
- `implement` roda `review-axes` e só reporta; uma lacuna de Spec vira 🔴 e o usuário precisa rodar tudo de novo.
- Ideia: uma rodada de correção com limite (Spec (a) faltando, (c) errado e violações obrigatórias de standard), depois roda de novo só o eixo Spec e então o Verdict. Achados de julgamento continuam 🟡.

## Atrito

### 5. Grilling não salva nada ⏳
- As decisões ficam só na conversa; `to-spec` depende da "current conversation". Compactação ou sessão nova perdem tudo.
- Ideia: `grilling` grava `.scratch/<slug>/DECISIONS.md` a cada rodada; `to-spec` lê esse arquivo quando existir.

### 6. Rodadas grandes demais no grilling ⏳
- "Ask the whole frontier" pode gerar 8 a 10 perguntas de uma vez.
- Ideia: limite de cerca de 5 por rodada, começando pelas que destravam mais decisões.

### 7. Tier Light do to-tickets não muda nada ⏳
- Standard e Light sugerem Sonnet os dois.
- Ideia: Light sugere Haiku, ou junta-se ao Standard.

### 8. Spec inchado com user stories ⏳
- "LONG / extremely extensive" gera ruído no subagente Spec (Haiku, limite de 400 palavras) e falsos "missing".
- Ideia: IDs de requisito `R1…Rn`, uma história por comportamento distinto; tickets declaram `Covers: R3, R5`; `review-axes` checa a cobertura por ID.

### 9. Passo Test do implement não define o que fazer quando a suíte falha ⏳
- Hoje basta "know its result".
- Ideia: falha causada pela mudança é corrigida antes do review; falha que já existia vai para o Verdict como 🟡.

### 10. Implement não confere bloqueios ⏳
- Começa um ticket mesmo com o `Blocked by` aberto.
- Ideia: checar o `Status:` dos bloqueadores primeiro e dar 🔴 se algum não estiver pronto.
- Questão relacionada: não existe status de "concluído" depois de `ready-for-human`, então não dá para calcular pelos arquivos quais tickets já podem começar.

## Detalhes

### 11. tdd: vermelho pelo motivo certo e fluxo de bug ⏳
- Falta a regra "o teste falha pelo motivo esperado" (erro de compilação ou import não conta).
- Falta o fluxo de bug: reproduzir como teste falhando antes de corrigir (a description promete isso).

### 12. review-axes: Haiku fraco para achar duplicação ⏳
- Ideia: eixo Standards em Sonnet quando o diff passar de cerca de 300 linhas.

### 13. to-spec: linha em branco depois do `---` do frontmatter ⏳
- YAML válido, mas destoa das outras skills.
