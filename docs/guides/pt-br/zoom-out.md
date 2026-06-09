# `/zoom-out` — Visão de Contexto de Alto Nível

## O que é

Uma skill simples e direta que diz ao agente para subir um nível de abstração e dar um mapa de todos os módulos relevantes e callers de uma área de código que você não conhece bem.

## Para que serve

- Quando você está olhando para um código que não conhece e precisa entender onde ele se encaixa no sistema maior
- Quando quer saber quem chama o quê antes de mudar algo
- Quando está perdido numa área da codebase e precisa de orientação
- Como ponto de partida antes de usar `/diagnose` ou `/tdd` numa área nova

## Como invocar

```
/zoom-out
```

Não precisa de argumentos adicionais. A skill diz ao agente exatamente o que fazer.

## Como funciona

É uma instrução direta ao agente:

> "Não conheço bem esta área do código. Sobe um nível de abstração. Me dá um mapa de todos os módulos relevantes e callers, usando o vocabulário do glossário de domínio do projeto."

O agente então:
1. Lê o `CONTEXT.md` para usar a linguagem correta do domínio
2. Mapeia os módulos envolvidos na área em questão
3. Mostra quem chama o quê, as dependências, o fluxo geral
4. Usa os termos do domínio (não nomes de arquivos internos ou jargão técnico genérico)

## Exemplo de uso

```
Preciso mudar o processo de cancelamento de pedidos mas não sei como o código funciona por aqui.

/zoom-out
```

O agente vai responder com algo como: "O fluxo de cancelamento envolve 3 módulos: OrderService (gerencia o estado do pedido), RefundProcessor (emite o reembolso), e NotificationQueue (notifica o cliente). O OrderService chama o RefundProcessor que por sua vez enfileira uma notificação..."

## Nota

Esta skill tem `disable-model-invocation: true` — significa que é uma instrução passada diretamente ao contexto do agente, sem lógica adicional de processamento. É intencionalmente simples: uma frase que reorienta o agente para a visão de alto nível.
