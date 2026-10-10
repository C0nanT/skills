```yaml
name: to-questionnaire
description: Transforme uma decisão que você não consegue responder sozinho em um questionário para outra pessoa preencher.
disable-model-invocation: true
```

Transforme algo que o usuário não consegue responder sozinho em um **questionário**: um documento em Markdown que ele entrega a uma pessoa para preencher de forma assíncrona, ou para preencher junto em uma reunião. O destinatário tem um conhecimento que o usuário não tem; o questionário extrai esse conhecimento dele.

**Entreviste sobre o envio, não sobre o assunto.** Pergunte ao usuário apenas sobre o _envio_, que ele sempre consegue responder: para quem vai e o que ele precisa receber de volta. As perguntas do documento então miram a **lacuna** entre o que o destinatário sabe e o que o usuário precisa.

1. **Para quem vai?** Pergunte, em uma única troca, o papel do destinatário, a expertise dele e a relação com o usuário. Isso define o tom do questionário e quanto contexto ele precisa carregar. Pronto quando você souber quem é o destinatário e o que ele sabe que o usuário não sabe.

2. **O que você precisa de volta?** Pergunte, em uma única troca, as decisões ou fatos específicos que o usuário não consegue resolver sozinho e precisa dessa pessoa. Pronto quando você tiver uma lista concreta do que o usuário precisa sair sabendo fazer ou decidir.

3. **Escreva o questionário.** Redija perguntas voltadas para a lacuna entre os passos 1 e 2, seguindo a estrutura de documento abaixo. Escreva em `to-questionnaire-<slug>.md` no diretório atual (o slug vem do tema) e informe o caminho. Pronto quando o arquivo existir e cada item que o usuário citou no passo 2 estiver coberto por uma pergunta.

## Estrutura do documento

Apresente o documento como um **questionário de descoberta**: o usuário não tem o contexto, o destinatário o tem. Ordene as perguntas da mais importante para a menos importante, já que em um formato assíncrono você pode ter apenas uma passada, e agrupe-as em títulos `##` por tema assim que houver mais de algumas. Escreva usando o modelo abaixo.

<questionnaire-template>

# [Título do questionário]

**Propósito:** por que este questionário existe e a decisão que depende dele.

**De:** <o usuário>, **Para:** <o destinatário>, **Como suas respostas serão usadas:** <para onde elas vão>

## Contexto

Um parágrafo que oriente um destinatário que não estava na cabeça do usuário. O suficiente para responder bem, não uma página.

## Como responder

Prazo e esforço aproximado. Respostas parciais e "não sei" são úteis: sinalize o que você não tem certeza em vez de pular.

## [Título do tema]

Uma seção `##` por tema. Abaixo dela, as perguntas, da mais importante para a menos importante. Cada pergunta trata de uma única ideia, nunca é composta, e tem logo abaixo um espaço para a resposta, além de uma linha de _por que isso importa_ apenas quando a pergunta puder ser mal interpretada ou provocar uma resposta descartável.

<question-example>
### Qual carga o sistema deve suportar no lançamento?

_Por que isso importa: decide se provisionamos para picos de tráfego agora ou adiamos._

>
</question-example>

## Mais alguma coisa?

Uma pergunta final que pega tudo: há algo que não perguntamos e que deveríamos saber?

</questionnaire-template>
