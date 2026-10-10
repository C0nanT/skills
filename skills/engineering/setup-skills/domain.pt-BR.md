# Documentos de domínio

Como as skills de engenharia devem consumir a documentação de domínio deste repositório ao explorar a base de código.

## Antes de explorar, leia estes arquivos

- **`GLOSSARY.md`** na raiz do repositório, ou
- **`GLOSSARY-MAP.md`** na raiz do repositório, se existir: ele aponta para um `GLOSSARY.md` por contexto. Leia cada um relevante para o assunto.
- **`docs/adr/`**: leia os ADRs que tocam a área em que você vai trabalhar. Em repositórios multi-contexto, verifique também `src/<context>/docs/adr/` para decisões de escopo de contexto.

Se algum desses arquivos não existir, **siga em silêncio**. Não aponte a ausência; não sugira criá-los de antemão. `/grill-with-docs` e `/improve-codebase-architecture` os criam sob demanda, quando termos ou decisões de fato são resolvidos.

## Estrutura de arquivos

Repositório de contexto único (a maioria dos repositórios):

```
/
├── GLOSSARY.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Repositório multi-contexto (presença de `GLOSSARY-MAP.md` na raiz):

```
/
├── GLOSSARY-MAP.md
├── docs/adr/                          ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── GLOSSARY.md
    │   └── docs/adr/                  ← context-specific decisions
    └── billing/
        ├── GLOSSARY.md
        └── docs/adr/
```

## Use o vocabulário do glossário

Quando a sua saída nomear um conceito de domínio (em um título de issue, uma proposta de refatoração, uma hipótese, um nome de teste), use o termo como definido no `GLOSSARY.md`. Não escorregue para sinônimos que o glossário evita explicitamente.

Se o conceito de que você precisa ainda não estiver no glossário, isso é um sinal: ou você está inventando uma linguagem que o projeto não usa (reconsidere), ou há uma lacuna real (anote-a e acrescente-a ao `GLOSSARY.md`).

## Sinalize conflitos com ADRs

Se a sua saída contradisser um ADR existente, traga isso à tona explicitamente, em vez de sobrescrevê-lo em silêncio:

> _Contradicts ADR-0007 (event-sourced orders), but worth reopening because…_
