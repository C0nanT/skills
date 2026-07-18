# `/to-spec` — Criar spec a partir da Conversa

## O que é

Uma skill que transforma o contexto da conversa atual em uma spec (também conhecida como PRD) estruturada e a publica no issue tracker do projeto.

## Para que serve

- Quando você já conversou sobre uma feature e quer formalizar em um spec
- Para criar um documento de requisitos antes de usar `/to-tickets`
- Quando quer ter um registro permanente no issue tracker do que foi decidido

## Como invocar

```
/to-spec
```

**Pré-requisito**: rode `/setup-skills` antes de usar pela primeira vez.

**Importante**: a skill *não faz entrevista*. Ela sintetiza o que já foi discutido na conversa. Se você ainda não discutiu a feature em detalhe, use `/grill-me` ou `/grill-with-docs` primeiro.

## Como funciona

**1. Explora a codebase** — lê o estado atual do código, usando o glossário de domínio para vocabulário consistente, respeitando ADRs na área em questão.

**2. Identifica seams de teste** — rascunha os pontos onde a feature será testada. Prefere seams existentes. Propõe novos seams no nível mais alto possível. Confirma com você que esses seams fazem sentido.

**3. Escreve e publica** — cria o spec usando o template e publica como issue com o label `ready-for-agent`.

### Template do spec

**Problem Statement** — o problema que o usuário enfrenta, da perspectiva do usuário.

**Solution** — a solução, da perspectiva do usuário.

**User Stories** — lista longa e numerada no formato:
```
1. Como [ator], quero [feature], para que [benefício]
```
Deve ser extensa e cobrir todos os aspectos da feature.

**Implementation Decisions** — decisões técnicas tomadas:
- Módulos que serão construídos/modificados
- Interfaces que serão modificadas
- Decisões arquiteturais
- Mudanças de schema
- Contratos de API

*Sem file paths ou code snippets* (ficam desatualizados rápido). Exceção: snippets de protótipos que codificam uma decisão mais precisamente que prosa.

**Testing Decisions** — o que torna um bom teste para essa feature, quais módulos serão testados, exemplos similares na codebase.

**Out of Scope** — o que explicitamente *não* está incluso neste spec.

**Further Notes** — observações adicionais.

## Exemplo de uso

```
[Após uma longa conversa sobre sistema de notificações]

Ótimo, acho que alinhamos tudo. Pode criar o spec?

/to-spec
```

O agente vai explorar a codebase, confirmar os seams de teste com você, e publicar o spec estruturado como issue.

## Dica de workflow típico

```
1. /grill-with-docs   ← alinha o design
2. /prototype         ← valida dúvidas específicas (opcional)
3. /to-spec            ← formaliza em spec
4. /to-tickets         ← quebra o spec em tickets implementáveis
5. /tdd               ← implementa cada ticket
```
