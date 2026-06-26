# `/review` — Revisar mudanças desde um ponto fixo

## O que é

Uma skill user-invoked que revisa o diff entre `HEAD` e um ponto fixo que você informa (commit, branch, tag, merge-base, etc.) em **dois eixos independentes**:

- **Standards** — o código segue os padrões documentados deste repositório?
- **Spec** — o código implementa fielmente o que a issue/PRD/spec pediu?

Os dois eixos rodam em **sub-agentes paralelos** para não contaminar o contexto um do outro; esta skill agrega os resultados lado a lado.

## Para que serve

- Revisar uma branch antes de abrir PR
- Auditar trabalho em progresso desde `main` ou outro ponto de referência
- Separar “código bonito mas errado” de “código certo mas fora do padrão”
- Validar implementação após `/implement`

## Como invocar

```
/review
```

Informe o **ponto fixo** — SHA de commit, nome de branch, tag, `main`, `HEAD~5`, etc. Se não disser qual, a skill pergunta.

Exemplos:

```
/review desde main
```

```
/review abc123f
```

```
/review .scratch/minha-feature/PRD.md
```

O último caso passa o caminho da spec explicitamente; útil quando o arquivo não bate com o nome da branch.

## Como funciona

### 1. Fixar o ponto de comparação

A skill captura o diff com `git diff <ponto-fixo>...HEAD` (três pontos, contra o merge-base) e lista os commits com `git log <ponto-fixo>..HEAD --oneline`.

Antes de seguir, confirma que a referência resolve (`git rev-parse`) e que o diff não está vazio. Referência inválida ou diff vazio falha aqui — não dentro dos sub-agentes.

### 2. Identificar a fonte da spec

Busca a spec nesta ordem:

1. Caminho que você passou como argumento
2. PRD/spec em `.scratch/`, `docs/` ou `specs/` que combine com o nome da branch ou feature (padrão para specs em markdown local)
3. Referências em mensagens de commit (`#123`, `Closes #45`, GitLab `!67`, etc.) — busca via `docs/agents/issue-tracker.md` (só quando há issue tracker remoto configurado)
4. Se nada for encontrado, pergunta onde está a spec. Se não houver spec, o eixo **Spec** é omitido e o relatório indica “no spec available”

Specs em markdown local **não precisam de setup**. Só specs em tracker remoto (GitHub/GitLab) exigem `/setup-skills`.

### 3. Identificar fontes de padrões

Qualquer arquivo do repo que documente como o código deve ser escrito — por exemplo `CODING_STANDARDS.md`, `CONTRIBUTING.md`, regras em `.cursor/rules/`, etc.

### 4. Rodar os dois sub-agentes em paralelo

Uma mensagem com duas chamadas `Agent` (`general-purpose`):

**Standards** — recebe o diff, a lista de commits e os arquivos de padrão. Reporta violações documentadas por arquivo/hunk, citando a regra (arquivo + trecho). Distingue violação clara de julgamento subjetivo. Ignora o que ferramentas já aplicam. Máximo ~400 palavras.

**Spec** — recebe o diff, a lista de commits e o conteúdo/caminho da spec. Reporta: (a) requisitos faltando ou parciais; (b) comportamento não pedido (scope creep); (c) requisitos aparentemente implementados mas com implementação suspeita. Cita a linha da spec em cada achado. Máximo ~400 palavras.

### 5. Agregar

Apresenta os dois relatórios sob `## Standards` e `## Spec`, verbatim ou levemente editados. **Não** mistura nem reordena achados entre eixos.

Encerra com um resumo de uma linha: total de achados por eixo e o pior problema **dentro de cada eixo** (se houver). Não escolhe “vencedor” entre os eixos — essa separação existe justamente para evitar isso.

## Por que dois eixos

Um mesmo change pode passar em um eixo e falhar no outro:

| Situação | Standards | Spec |
|----------|-----------|------|
| Código segue todos os padrões, mas implementa a coisa errada | pass | fail |
| Código faz exatamente o que a issue pediu, mas quebra convenções do projeto | fail | pass |

Reportar separado impede que um eixo mascare o outro.

## Exemplos de uso

### Depois de `/implement` (fluxo típico)

Você implementou a issue na branch `feat/pipeline-improvements`. O PRD está em `.scratch/pipeline-improvements/PRD.md` e a skill acha sozinha.

```
/review desde main
```

O agente compara `main...HEAD`, roda Standards e Spec em paralelo e devolve algo neste formato:

```markdown
## Standards
- `scripts/foo.sh`: função sem `set -euo pipefail` — viola CONTRIBUTING.md §Shell scripts
- …

## Spec
- PRD user story #3 pede “falhar cedo se plugin.json inconsistente”; diff só valida README — parcial
- …

Standards: 2 achados (pior: shell sem fail-fast). Spec: 1 achado (requisito #3 incompleto).
```

### Antes de abrir PR

Branch pronta; quer checar tudo que mudou desde que saiu de `main`:

```
/review main
```

Mesmo efeito que `desde main` — o ponto fixo é a branch base do PR.

### Spec em caminho que a skill não adivinha

Branch `fix/error-accumulation`, mas o PRD está num slug diferente:

```
/review main .scratch/pipeline-improvements/issues/01-fix-error-accumulation.md
```

O segundo argumento aponta a issue como spec; o diff ainda é `main...HEAD`.

### Só os últimos commits

Trabalho grande na branch; quer revisar só o que fez hoje:

```
/review HEAD~3
```

Spec: a skill ainda tenta achar PRD/issue pelo nome da branch ou pelos commits — se não achar, pergunta ou omite o eixo Spec.

### Sem spec (só padrões do repo)

Refatoração interna, sem issue/PRD:

```
/review origin/main
```

Quando você disser que não há spec, o relatório traz só `## Standards` e anota que Spec foi omitido.

### Issue no GitHub (tracker remoto)

Commits com `Closes #42` e `/setup-skills` já configurado:

```
/review main
```

A skill busca a issue #42 via `docs/agents/issue-tracker.md` e usa o corpo dela como spec.

## Onde entra no fluxo

No fluxo principal (`/ask-skills`):

- Após **`/implement`** — revisão automática do trabalho feito na sessão
- Antes de abrir PR — compare contra `main` ou a branch base
- Revisão ad hoc — qualquer diff desde um ponto que você nomear

## Dicas

- Sempre informe o ponto fixo; sem ele a skill não sabe o que comparar.
- Para specs locais, deixe o PRD em `.scratch/<feature>/` com nome alinhado à branch — a skill encontra sozinha.
- Se só quiser checagem de padrão ou só de spec, ainda assim rode `/review`; o eixo sem spec aparece como omitido, não como “passou”.
- Não espere um veredito único “aprovado/reprovado”; leia os dois relatórios separadamente.
