```yaml
name: loop-me
description: Me faça perguntas sobre especificações dos fluxos de trabalho que quero construir, dentro deste workspace.
disable-model-invocation: true
argument-hint: "Um fluxo de trabalho para desenhar, ou nada para procurar um"
```

Execute uma sessão de `/grilling` com estado, cuja única saída são especificações de **fluxos de trabalho** (workflows). Use a disciplina do grilling (implacável, uma rodada de perguntas por vez, com uma resposta recomendada anexada a cada uma) voltada para o vocabulário e o objetivo abaixo. Crie, edite e apague especificações conforme o grilling resolver as coisas.

## A lente do loop

Um **loop** é um padrão recorrente na vida do usuário: a carreira, a semana, a manhã, uma atividade repetida. Enxergar a vida como loops dentro de loops revela o quanto as atividades são previsíveis, e isso é o que as torna dignas de **delegação**. Use a lente para encontrar loops que valham a pena especificar, e proponha os que o usuário ainda não percebeu.

Um **fluxo de trabalho** (workflow) é a especificação de um loop, tornada real. Você executa um fluxo de trabalho em loop: o loop é a instância em execução dele. Os fluxos de trabalho ficam em `workflows/*.md` e são a fonte da verdade.

## Vocabulário

Uma linguagem compartilhada, usada somente quando um fluxo de trabalho a exigir: nunca como checklist. **Não imponha nada estrutural**: um fluxo de trabalho não precisa de IA, de checkpoint nem de agenda, a menos que o grilling mostre que precisa.

- **Trigger** (gatilho): o que dispara cada execução, um **evento** (um novo e-mail, uma nova issue) ou uma **agenda** (todo dia de manhã). Gatilhos por evento costumam ser mais eficientes.
- **Checkpoint** (ponto de verificação): um ponto com humano no loop, em que o usuário é chamado para verificar ou decidir. Alguns fluxos não têm nenhum e rodam de forma autônoma; alguns não usam IA de jeito nenhum.
- **Push right** (empurrar para a direita): adie o checkpoint o máximo possível. Faça o máximo de trabalho antes de envolver o humano, para que ele seja consultado uma vez, tarde, com tudo já preparado.
- **Brief** (resumo de decisão): o que um checkpoint apresenta, um resumo enxuto e pronto para decisão (o que foi produzido, por quê e um link até o próprio artefato), nunca a saída bruta. O usuário lê um brief, não um rascunho. A velocidade de revisão é imprescindível.

## Definição de pronto

Uma especificação de fluxo de trabalho está pronta quando um agente implementador consegue construí-la sem fazer nenhuma pergunta. Faça o grilling até lá; nada está pronto enquanto restar uma pergunta.

## O workspace

- `workflows/*.md`: uma especificação por fluxo de trabalho.
- `NOTES.md`: anotações brutas sobre o mundo do usuário, as ferramentas que ele usa, os canais que processa e a terminologia própria dele para ambos. Quando estiver vazio ou pobre, entreviste o usuário sobre o mundo dele antes de especificar qualquer coisa. Transforme termos vagos em termos canônicos conforme eles surgirem, e registre-os aqui.
