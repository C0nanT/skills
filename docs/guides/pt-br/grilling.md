# `/grilling` — Entrevista relentless sobre um plano

## O que é

A skill **model-invoked** que conduz a entrevista implacável sobre um plano ou design — uma pergunta por vez, com resposta recomendada, até resolver cada ramo da árvore de decisões.

`/grill-me` e `/grill-with-docs` são wrappers user-invoked que delegam aqui.

## Para que serve

- Stress-testar um plano antes de construir
- Resolver ambiguidades antes de código
- Base compartilhada para grilling genérico (`/grill-me`) e com docs (`/grill-with-docs`)

## Como invocar

Model-invoked — frases como "grill me", "stress-test this plan". User-invoked via:

```
/grill-me          ← sem codebase, stateless
/grill-with-docs   ← com CONTEXT.md, ADRs, /domain-modeling
```

Ou diretamente (se você souber o nome):

```
/grilling
```

## Como funciona

- **Uma pergunta por vez** — espera feedback antes da próxima. Várias perguntas de uma vez confundem.
- **Resposta recomendada** em cada pergunta — você concorda, discorda ou refina.
- **Explora a codebase** quando a resposta está no código, em vez de perguntar ao humano.
- **Árvore de decisões** — resolve dependências entre decisões sequencialmente até entendimento compartilhado.

## Diferenças entre wrappers

| Skill | Invocação | Persiste docs? |
|-------|-----------|----------------|
| `/grilling` | model | depende do contexto |
| `/grill-me` | user | não — stateless |
| `/grill-with-docs` | user | sim — `CONTEXT.md`, ADRs via `/domain-modeling` |

## Exemplo de uso

```
Quero notificações em tempo real quando alguém comenta numa tarefa.

/grill-me
```

O agente pergunta canal (WebSocket vs SSE vs polling), autenticação, persistência — um tópico por vez.

## Dicas

- 10 minutos de grilling economizam horas de retrabalho por desalinhamento.
- Com codebase existente, prefira `/grill-with-docs` para não perder terminologia.
