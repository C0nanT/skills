# `/ask-matt` — Qual skill ou fluxo usar?

## O que é

Uma skill roteadora sobre as skills **user-invoked** deste repositório. Você não precisa memorizar cada skill — descreva a situação e o agente indica o fluxo certo.

## Para que serve

- Quando não sabe qual skill invocar
- Para entender como as skills se encaixam num workflow maior
- Quando quer saber se deve ir para `/grill-with-docs`, `/implement`, etc.

## Como invocar

```
/ask-matt
```

Descreva o que você quer fazer na mesma mensagem ou na conversa anterior.

## Fluxo principal: ideia → ship

O caminho que a maior parte do trabalho percorre:

1. **`/grill-with-docs`** — afia a ideia por entrevista. Comece aqui quando **há codebase** (persiste em `CONTEXT.md` e ADRs). Sem codebase? Use **`/grill-me`** (standalone).
2. **Branch — dá para resolver tudo na conversa?** Se alguma pergunta precisa de código executável (estado, lógica, UI), desvie para **`/prototype`**, usando **`/handoff`** nos dois sentidos:
   - `/handoff` para sair, abrir sessão nova referenciando o arquivo,
   - `/prototype` para responder com código descartável,
   - `/handoff` de volta com o que aprendeu.
3. **Branch — build multi-sessão?**
   - **Sim** → **`/to-prd`** → **`/to-issues`**. Entre cada issue, **limpe o contexto**: sessão nova por issue e **`/implement`** com o PRD + a issue.
   - **Não** → **`/implement`** na mesma janela de contexto.

### Higiene de contexto

Mantenha os passos 1–3 numa **única janela** até depois de `/to-issues`. Cada `/implement` começa fresco, lendo a issue.

Se a sessão se aproximar da [smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone) (~120k tokens) antes de `/to-issues`, use `/handoff` e continue numa thread nova — não empurre com contexto degradado.

## Saúde da codebase

- **`/improve-codebase-architecture`** — quando tiver um tempo livre. Surfa oportunidades de aprofundamento; escolher uma gera uma ideia para levar ao `/grill-with-docs`.

## Cruzando sessões

- **`/handoff`** — compacta a conversa num markdown. Abra **sessão nova** referenciando o arquivo. Ponte entre janelas de contexto.
- **`/compact`** (built-in) — resume no **mesmo** chat. Use em quebras intencionais entre fases, não no meio de uma. `/handoff` bifurca; `/compact` continua.

## Standalone

Fora do fluxo principal:

- **`/grill-me`** — mesma entrevista que `/grill-with-docs`, sem codebase. Não grava `CONTEXT.md`.
- **`/writing-great-skills`** — referência para escrever e editar skills bem.

## Pré-requisito

Rode **`/setup-skills`** antes do primeiro fluxo de engenharia (issue tracker, labels de triage, layout de docs). Issue trackers customizados também funcionam.
