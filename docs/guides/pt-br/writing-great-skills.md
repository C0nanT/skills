# `/writing-great-skills` — Referência para escrever skills bem

## O que é

Uma skill user-invoked de **referência** (não um wizard de criação) sobre vocabulário e princípios que tornam uma skill **previsível** — o agente segue o mesmo *processo* a cada execução.

Termos em negrito no `SKILL.md` estão definidos em [GLOSSARY.md](../../../skills/productivity/writing-great-skills/GLOSSARY.md).

## Para que serve

- Escrever ou editar skills no repositório
- Entender model-invoked vs user-invoked
- Diagnosticar skills com sediment, sprawl ou premature completion
- Aprender quando dividir skills e como escrever descriptions

## Como invocar

```
/writing-great-skills
```

Consulte durante revisão de um `SKILL.md` ou ao planejar uma skill nova.

## Invocação: duas modalidades

| Tipo | Mecânica | Custo |
|------|----------|-------|
| **Model-invoked** | Omitir `disable-model-invocation`; description rica com gatilhos | **Context load** — description sempre na janela |
| **User-invoked** | `disable-model-invocation: true`; description só para humanos | **Cognitive load** — você precisa lembrar que existe |

Use model-invoked só quando o agente (ou outra skill) precisa alcançar sozinho. Skills só por comando manual → user-invoked.

Muitas skills user-invoked → use uma **router skill** (ex.: `/ask-matt`).

## Escrevendo a description

Para model-invoked, a description faz invocação:

- **Leading word** na frente
- **Um gatilho por branch** — sinônimos da mesma branch são duplicação
- Corte identidade que já está no corpo

## Hierarquia de informação

1. **In-skill step** — ação ordenada com **completion criterion** checkável (e exaustivo quando importa)
2. **In-skill reference** — definições consultadas sob demanda no `SKILL.md`
3. **External reference** — arquivo separado via **context pointer** (ex.: `GLOSSARY.md`)

**Progressive disclosure** — empurra referência para baixo na escala. **Branching**: inline o que todo branch precisa; pointer só para o que alguns branches usam.

**Co-location** — definição, regras e caveats sob o mesmo heading.

## Quando dividir (granularity)

- **Por invocação** — novo leading word que deve disparar sozinho, ou outra skill precisa alcançar → paga context load
- **Por sequência** — passos futuros tentam o agente a **premature completion** → esconda post-completion steps

## Pruning

- **Single source of truth** por significado
- Teste **no-op** por frase: muda comportamento vs default do modelo? Se não, delete a frase inteira

## Leading words

Conceito compacto do pré-treino (_lesson_, _tight_, _red_) repetido para ancorar execução e invocação. Ex.: "loop que você acredita" → _red_; "rápido, determinístico" → _tight_.

## Failure modes

| Modo | Sintoma | Defesa |
|------|---------|--------|
| **Premature completion** | Termina passo cedo | Sharpen criterion; split por sequência se necessário |
| **Duplication** | Mesmo significado em vários lugares | Colapse numa fonte |
| **Sediment** | Camadas obsoletas acumuladas | Disciplina de pruning |
| **Sprawl** | Skill longa demais | Disclosure + split por branch |
| **No-op** | Linha que o modelo já obedece | Delete ou leading word mais forte |

## Onde colocar skills novas

Depois de escrever, escolha o bucket em `skills/`:

- `engineering/`, `productivity/`, `misc/` — promovidas (README + plugin.json)
- `personal/`, `in-progress/` — não promovidas

Estrutura típica:

```
skill-name/
├── SKILL.md
├── REFERENCE.md ou GLOSSARY.md (se necessário)
└── scripts/ (se operações determinísticas)
```

## Dicas

- Previsibilidade de *processo* > mesma saída literal
- Completion criteria vagos convidam premature completion
- Description de model-invoked: cada palavra paga context load — poda agressivamente
