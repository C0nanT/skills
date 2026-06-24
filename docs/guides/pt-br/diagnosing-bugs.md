# `/diagnosing-bugs` — Diagnóstico disciplinado de bugs

## O que é

Uma skill (model-invoked) para bugs difíceis e regressões de performance. Em vez de olhar o código e adivinhar, força um processo em 6 fases — sendo a Fase 1 (loop de feedback) o coração de tudo.

## Para que serve

- Bugs que você não reproduz de forma consistente
- Performance que piorou sem causa óbvia
- Erros intermitentes
- Quando já passou muito tempo no código sem progresso

## Como invocar

Model-invoked — o agente carrega quando você diz "diagnose", "debug this", ou descreve algo quebrado/lento. Também pode invocar:

```
/diagnosing-bugs
```

Descreva o bug na mesma mensagem ou numa anterior.

## Como funciona

### Fase 1 — Construir um loop de feedback

**Esta é a skill.** Sem um sinal pass/fail **tight** que fica vermelho *neste* bug, bissecção e hipóteses não salvam.

Ordem aproximada de tentativas:

1. Teste falhando no seam certo (unit, integração, e2e)
2. Script `curl` / HTTP contra dev server
3. CLI com fixture, diff de stdout
4. Browser headless (Playwright/Puppeteer)
5. Replay de trace capturado
6. Harness descartável mínimo
7. Property/fuzz (1000 inputs)
8. Bisection harness (`git bisect run`)
9. Loop diferencial (versão antiga vs nova)
10. HITL bash script (último recurso)

**Apertar o loop:** mais rápido, sinal mais nítido, mais determinístico.

**Bugs não-determinísticos:** objetivo é **taxa de reprodução maior**, não repro limpo. 50% de flake é debugável; 1% não.

**Critério de conclusão:** um comando nomeado, já executado, que é red-capable, determinístico, rápido (segundos) e agent-runnable. Sem comando red-capable, **não** avance para Fase 2.

### Fase 2 — Reproduzir + minimizar

Confirme que o loop reproduz o sintoma **do usuário**, não um bug vizinho. Depois **minimize**: corte inputs, callers, config — um de cada vez, re-rodando o loop. Pare quando cada elemento restante for load-bearing.

### Fase 3 — Hipóteses

3–5 hipóteses ranqueadas, cada uma falsificável: *"Se X for a causa, mudar Y fará o bug sumir."* Mostre a lista ao usuário antes de testar.

### Fase 4 — Instrumentar

Uma variável por vez, mapeada a uma hipótese. Preferência: debugger/REPL > logs pontuais. Marque logs com prefixo único (`[DEBUG-a4f2]`). Regressões de performance: meça primeiro (profiler, timing), não logue tudo.

### Fase 5 — Fix + teste de regressão

Teste de regressão **antes** do fix — só se houver **seam correto** (padrão real do bug no call site). Sem seam correto, isso é achado arquitetural; encaminhe para `/improve-codebase-architecture` depois.

### Fase 6 — Limpeza + post-mortem

- Loop original passa
- Teste de regressão passa (ou ausência de seam documentada)
- Instrumentação `[DEBUG-...]` removida
- Protótipos descartados
- Hipótese correta no commit/PR

Pergunte: o que teria prevenido o bug? Se for mudança arquitetural, use `/improve-codebase-architecture` **depois** do fix.

## Exemplo de uso

```
O checkout às vezes salva ordem como "pendente" após pagamento aprovado. Só em produção.

/diagnosing-bugs
```

O agente vai priorizar construir um loop (ex.: replay de trace de produção) antes de qualquer teoria.

## Dicas

- Não pule a Fase 1. Loop de 2 segundos é superpoder.
- Leia `CONTEXT.md` e ADRs da área ao explorar o código.
- Hipótese antes de loop red-capable é o failure mode exato que esta skill previne.
