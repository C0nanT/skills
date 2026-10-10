# Mecânica de skills

O ramo específico de skills de [`writing-for-agents`](TRADUCAO.pt-BR.md): o que muda quando o documento é uma skill (frontmatter, a escolha de invocação e as skills roteadoras). Todo o resto sobre a escrita está na referência universal em `TRADUCAO.pt-BR.md`.

## Invocação

Duas escolhas, que trocam as duas cargas:

- Uma skill **invocada pelo modelo** mantém uma `description`, para que o agente possa disparála de forma autônoma, e outras skills possam alcançá-la. Você ainda pode digitar o nome dela: a invocação pelo modelo sempre _inclui_ o alcance do usuário; a descrição só acrescenta a descoberta pelo agente, nunca remove a do humano. A descrição é o ponteiro de contexto de nível superior da skill, obrigatoriamente mantido carregado o tempo todo: carga de contexto permanente em troca de descobribilidade. Uma skill invocada pelo modelo cujo conteúdo é todo referência também é um lar compartilhado para referência: outra skill pode invocá-la, então a referência que várias skills precisam fica em um só lugar. Mecânica: omita `disable-model-invocation` e escreva uma descrição voltada ao modelo que carregue os ramos de gatilho (as regras de escrita de ponteiros em `TRADUCAO.pt-BR.md` se aplicam por completo).
- Uma skill **invocada pelo usuário** remove a descrição do alcance do agente: só o humano que digita o nome dela pode invocá-la, e nenhuma outra skill consegue. Carga de contexto zero, mas gasta carga cognitiva: você é o índice que precisa lembrar que ela existe. Mecânica: defina `disable-model-invocation: true`; a `description` passa a ser voltada ao humano: um resumo de uma linha, sem listas de gatilho.

Escolha a invocação pelo modelo somente quando o agente precisar alcançar a skill sozinho, ou quando outra skill precisar dela. Se ela só vai ser disparada à mão, torne-a invocada pelo usuário e não pague carga de contexto nenhuma.

Referência compartilhada que duas skills invocadas pelo usuário precisam não pode morar em nenhuma das duas: sem descrições, nenhuma consegue disparar a outra. Empurre-a para um arquivo simples fora do sistema de skills: referência externa a que qualquer skill pode apontar.

## Dividir por invocação

O corte por invocação da divisão (o corte por sequência está em `TRADUCAO.pt-BR.md`): separe uma skill invocada pelo modelo quando você tiver uma palavra-guia distinta que deve disparála sozinha (uma palavra de gatilho que você de fato usa nos seus prompts), ou quando outra skill precisar alcançá-la. Você paga carga de contexto pela nova descrição sempre carregada, então esse alcance independente precisa valer a pena.

## Skills roteadoras

Quando as skills invocadas pelo usuário se multiplicam além do que você consegue lembrar, essa carga cognitiva acumulada é curada por uma **skill roteadora**: uma skill invocada pelo usuário que nomeia as outras e indica quando usar cada uma, para que o humano tenha uma skill para lembrar em vez de muitas. Ela só pode sugerir, nunca disparar: skills invocadas pelo usuário não têm descrição, então nada além do humano consegue alcançá-las.
