# `/codebase-design` — Vocabulário para módulos profundos

## O que é

Uma skill de referência (model-invoked) com vocabulário compartilhado para projetar **módulos profundos**: muita comportamento atrás de uma interface pequena, num seam limpo, testável por essa interface.

Outras skills (como `/tdd` e `/improve-codebase-architecture`) podem acionar este vocabulário automaticamente.

## Para que serve

- Projetar ou melhorar a interface de um módulo
- Decidir onde colocar um seam
- Tornar código mais testável ou navegável para agentes
- Discutir profundidade vs. módulos rasos com linguagem precisa

## Como invocar

Model-invoked — o agente pode carregar ao discutir design de módulos. Você também pode pedir explicitamente:

```
/codebase-design
```

Ou mencione: "módulo profundo", "onde fica o seam", "interface pequena".

## Glossário (termos exatos)

| Termo | Significado |
|-------|-------------|
| **Module** | Qualquer coisa com interface e implementação (função, classe, pacote). Não use "component" ou "service". |
| **Interface** | Tudo que o caller precisa saber: assinatura, invariantes, erros, config, performance. Mais que a keyword `interface` do TypeScript. |
| **Implementation** | O corpo interno do módulo. Distinto de **Adapter**. |
| **Depth** | Comportamento exercitável por unidade de interface aprendida. **Deep** = muita implementação, interface pequena. |
| **Seam** | Onde o comportamento pode mudar sem editar naquele ponto — a *localização* da interface. |
| **Adapter** | Implementação concreta num seam. |
| **Leverage** | O que callers ganham com profundidade. |
| **Locality** | O que maintainers ganham: mudanças concentradas num lugar. |

## Deep vs shallow

**Deep** — interface pequena, implementação rica. **Shallow** — interface quase tão complexa quanto o interior (evitar).

Ao projetar, pergunte: dá para reduzir métodos? Simplificar parâmetros? Esconder mais complexidade?

## Princípios-chave

- **Profundidade é propriedade da interface**, não do tamanho do arquivo.
- **Teste de deleção** — apagar o módulo: complexidade some (pass-through) ou reaparece em N callers (estava valendo a pena)?
- **A interface é a superfície de teste** — callers e testes cruzam o mesmo seam.
- **Um adapter = seam hipotético. Dois adapters = seam real.**

## Testabilidade

1. **Aceite dependências, não crie** — injete `paymentGateway`, não `new StripeGateway()` dentro.
2. **Retorne resultados, não efeitos colaterais** — `calculateDiscount(cart)` em vez de mutar `cart.total`.
3. **Superfície pequena** — menos métodos e parâmetros = setup de teste mais simples.

## Referências no skill

- [DEEPENING.md](../../../skills/engineering/codebase-design/DEEPENING.md) — aprofundar um cluster dado suas dependências.
- [DESIGN-IT-TWICE.md](../../../skills/engineering/codebase-design/DESIGN-IT-TWICE.md) — explorar interfaces alternativas em paralelo.

## Dicas

- Use os termos do glossário de forma consistente — o ponto é uma linguagem compartilhada.
- Se o módulo só tem um adapter, questione se o seam é necessário.
