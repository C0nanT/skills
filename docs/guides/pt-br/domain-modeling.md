# `/domain-modeling` — Modelagem de domínio ativa

## O que é

Uma skill (model-invoked) para **construir e afiar** o modelo de domínio do projeto: desafiar termos, inventar cenários de borda, escrever glossário e ADRs no momento em que cristalizam.

Ler `CONTEXT.md` por vocabulário é hábito de qualquer skill — **esta** skill é para quando você está **mudando** o modelo, não só consumindo.

`/grill-with-docs` delega a esta skill durante entrevistas com codebase.

## Para que serve

- Fixar terminologia e linguagem ubíqua
- Registrar decisão arquitetural (ADR)
- Manter `CONTEXT.md` alinhado com o que você decide na conversa

## Como invocar

Model-invoked — acionada por `/grill-with-docs` e por pedidos de glossário/ADR. Também:

```
/domain-modeling
```

## Estrutura de arquivos

Contexto único:

```
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

Multi-contexto (se existir `CONTEXT-MAP.md`):

```
/
├── CONTEXT-MAP.md
├── docs/adr/              ← decisões system-wide
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

Arquivos são criados **lazy** — só quando há algo a escrever.

## Durante a sessão

- **Desafia o glossário** — termo conflita com `CONTEXT.md`? Chama na hora.
- **Afina linguagem vaga** — "conta" é Customer ou User?
- **Cenários concretos** — força precisão nas bordas entre conceitos.
- **Cruza com código** — afirmação vs implementação: expõe contradições.
- **Atualiza `CONTEXT.md` inline** — sem acumular para depois. Formato em [CONTEXT-FORMAT.md](../../../skills/engineering/domain-modeling/CONTEXT-FORMAT.md).

`CONTEXT.md` é **só glossário** — sem detalhes de implementação, spec ou scratch pad.

## Quando criar ADR

Só quando **as três** forem verdadeiras:

1. Difícil de reverter
2. Surpreendente sem contexto
3. Resultado de trade-off real entre alternativas

Formato em [ADR-FORMAT.md](../../../skills/engineering/domain-modeling/ADR-FORMAT.md).

## Diferença de `/grill-with-docs`

`/grill-with-docs` é user-invoked e roda uma sessão `/grilling` **usando** `/domain-modeling`. Esta skill é a disciplina de documentação; aquela é o ponto de entrada humano no fluxo de engenharia.

## Dicas

- Não trate `CONTEXT.md` como spec de implementação.
- ADR em excesso vira ruído — seja parcimonioso.
