# `/teach` — Ensinar um conceito em múltiplas sessões

## O que é

Uma skill user-invoked que ensina um tópico ao longo de várias sessões, usando o **diretório atual** como workspace de aprendizado com estado persistente.

## Para que serve

- Aprender uma skill ou conceito novo com lições estruturadas
- Curso personalizado com missão, lições HTML e registros de aprendizado
- Retomar de onde parou em sessões futuras

## Como invocar

```
/teach
```

Ou com o tópico:

```
/teach TypeScript generics
```

## Workspace de ensino

O agente trata o diretório atual como estado da aprendizagem:

| Arquivo / pasta | Função |
|-----------------|--------|
| `MISSION.md` | Por que você quer aprender (formato em MISSION-FORMAT.md) |
| `./reference/*.html` | Cheat sheets, glossários, referência rápida |
| `RESOURCES.md` | Fontes externas confiáveis |
| `./learning-records/*.md` | Lições aprendidas (tipo ADR), zona proximal |
| `./lessons/*.html` | Lições autocontidas, numeradas `0001-...` |
| `./assets/*` | Componentes reutilizáveis (CSS, quizzes, widgets) |
| `NOTES.md` | Preferências e notas de trabalho |

## Filosofia

Três pilares:

- **Knowledge** — de recursos de alta confiança (não confie só no conhecimento paramétrico do modelo)
- **Skills** — lições interativas com feedback apertado
- **Wisdom** — interação com comunidade real quando aplicável

Separe **fluency** (recall no momento) de **storage strength** (retenção longa). Priorize dificuldade desejável: retrieval practice, spacing, interleaving (para prática de skills).

## Lições

- Uma lição = um HTML em `./lessons/`, curta, bonita (tipografia limpa), um win tangível
- Liga a outras lições e referências por âncoras HTML
- Cita fonte primária externa
- Lembra o aluno de fazer perguntas de follow-up ao agente
- Reutilize `./assets/` antes de inline código duplicado

## Fluxo típico

1. Se `MISSION.md` vazio, o agente pergunta **por que** você quer aprender
2. Popula `RESOURCES.md` com fontes confiáveis
3. Lê `learning-records` para calibrar zona de desenvolvimento proximal
4. Produz próxima lição no nível certo de desafio
5. Atualiza registros e referências conforme avança

## Dicas

- Confirme mudanças de missão com o usuário antes de reescrever `MISSION.md`
- Para tópicos mais práticos (yoga, código), priorize skills; para teóricos, knowledge
- Glossário em `./reference/` deve ser seguido em todas as lições depois de criado
