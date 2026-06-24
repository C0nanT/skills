# `/grill-me` — Entrevista Relentless sobre seu Plano

## O que é

Uma skill user-invoked que inicia uma sessão **`/grilling`** — entrevista intensa sobre um plano ou design, resolvendo cada ramificação da árvore de decisões uma por uma. Stateless: não grava `CONTEXT.md` nem ADRs.

## Para que serve

- Antes de começar a implementar uma feature nova
- Quando você tem uma ideia mas ela ainda está nebulosa
- Quando quer stress-testar um design antes de se comprometer com ele
- Quando precisa pensar em voz alta com alguém que vai fazer perguntas difíceis
- Para alinhar com o agente antes que ele escreva código

## Como invocar

```
/grill-me
```

Descreva o que você quer construir, ou traga a conversa que já teve. A skill vai começar a entrevistar você.

## Como funciona

O agente assume o papel de entrevistador implacável. Para cada aspecto do plano:

1. **Faz uma pergunta por vez** — não despeja 10 perguntas de uma vez. Espera sua resposta antes de continuar.

2. **Propõe uma resposta recomendada** — para cada pergunta, o agente já diz o que *ele* acha que é a melhor resposta. Você pode concordar, discordar, ou refinar.

3. **Explora a codebase quando necessário** — se uma pergunta pode ser respondida lendo o código existente, o agente faz isso em vez de perguntar.

4. **Desce a árvore de decisões** — resolve dependências entre decisões. Só pergunta sobre uma coisa depois que a anterior estiver resolvida.

O processo continua até que *todos* os ramos da árvore de decisões estejam resolvidos e exista um entendimento compartilhado completo.

## Diferença de `/grill-with-docs`

Ambas delegam a **`/grilling`** por baixo.

`/grill-me` é genérico — qualquer plano, com ou sem codebase. Não persiste documentação.

`/grill-with-docs` é para engenharia com codebase: a mesma entrevista, mas também trabalha os docs de domínio — lê e atualiza `CONTEXT.md`, verifica ADRs, oferece criar ADRs quando o trade-off justifica.

## Exemplo de uso

```
Quero criar um sistema de notificações em tempo real para o app. Os usuários devem receber alertas quando alguém comentar numa tarefa deles.

/grill-me
```

O agente vai começar a fazer perguntas: "Por qual canal: WebSockets, SSE, ou polling? Minha recomendação é SSE porque..." — e assim por diante até cobrir transporte, autenticação, persistência, leitura de notificações, etc.

## Por que usar

O problema mais comum com agentes de IA é desalinhamento: o agente constrói algo diferente do que você queria. Uma sessão de grilling antes de implementar é o antídoto. Custa 10 minutos e economiza horas de retrabalho.
