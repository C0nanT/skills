# `/diagnose` — Diagnóstico Disciplinado de Bugs

## O que é

Uma skill para depurar bugs difíceis e regressões de performance de forma sistemática. Em vez de "olhar o código e tentar adivinhar", ela força um processo disciplinado que quase sempre encontra a causa raiz.

## Para que serve

- Bugs que você não consegue reproduzir consistentemente
- Performance que piorou mas você não sabe por quê
- Erros intermitentes ou "às vezes acontece"
- Qualquer situação em que você já ficou olhando o código por muito tempo sem chegar a lugar nenhum

## Como invocar

```
/diagnose
```

Descreva o bug na mesma mensagem ou numa mensagem anterior. A skill vai conduzir o processo a partir daí.

## Como funciona

A skill opera em **6 fases**:

### Fase 1 — Construir um loop de feedback

**Esta é a parte mais importante.** O objetivo é criar uma forma automática, rápida e determinística de reproduzir o bug — um script, teste, ou comando que resulte em "passou" ou "falhou".

Exemplos do que pode ser usado:
- Um teste automatizado (unitário, integração, e2e)
- Um script `curl` contra o servidor local
- Um script Playwright que abre o browser e clica nas coisas certas
- Uma invocação de CLI com um input fixo
- Um script que roda o mesmo input 1000 vezes em busca da falha

Se não for possível construir esse loop, a skill para e pede ajuda ao usuário (acesso ao ambiente, logs capturados, etc.).

### Fase 2 — Reproduzir

Confirma que o loop realmente reproduz o bug descrito, não outro bug parecido.

### Fase 3 — Hipóteses

Gera 3–5 hipóteses ranqueadas antes de testar qualquer uma. Cada hipótese precisa ser falsificável: "se X for a causa, então mudar Y vai fazer o bug sumir". Mostra a lista para o usuário antes de testar — alguém com contexto do domínio frequentemente re-rankeia na hora.

### Fase 4 — Instrumentar

Testa as hipóteses uma por vez. Prefere debugger/REPL a logs. Todo log de debug fica marcado com um prefixo único (ex: `[DEBUG-a4f2]`) para fácil limpeza depois.

### Fase 5 — Corrigir + teste de regressão

Escreve o teste de regressão *antes* do fix, se existir um bom "seam" (ponto de teste). Aplica o fix. Verifica que o loop original passa.

### Fase 6 — Limpeza + post-mortem

Remove todos os logs de debug, deleta protótipos temporários, documenta o que causou o bug no commit/PR. Pergunta: o que teria prevenido esse bug? Se a resposta envolver mudança arquitetural, encaminha para `/improve-codebase-architecture`.

## Exemplo de uso

```
Temos um bug no checkout: às vezes a ordem é salva com status "pendente" mesmo após o pagamento ser aprovado. Acontece só em produção, não consigo reproduzir local.

/diagnose
```

A skill vai guiar você pela construção de um loop de feedback (talvez um replay de um trace capturado de produção), depois pelas hipóteses, instrumentação, e fix.

## Dicas

- Não pule a Fase 1. Um loop de feedback de 2 segundos é um superpoder. Sem ele, você está voando às cegas.
- Para bugs não-determinísticos, o objetivo não é uma reprodução limpa — é uma *taxa de reprodução maior*. Rode 100 vezes, adicione estresse, paralelise.
