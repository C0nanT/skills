```yaml
name: handoff
description: Compacte a conversa atual em um documento de handoff para que outro agente possa dar continuidade.
argument-hint: "Para que a próxima sessão será usada?"
disable-model-invocation: true
```

Escreva um documento de handoff que resuma a conversa atual, para que um agente novo possa continuar o trabalho. Salve-o no diretório temporário do sistema operacional do usuário (`$TMPDIR`, senão `/tmp`; `%TEMP%` no Windows), e não no workspace atual.

Inclua no documento uma seção "suggested skills", indicando quais skills o próximo agente deve chamar com a ferramenta Skill.

Não repita conteúdo já registrado em outros artefatos (especificações, planos, ADRs, issues, commits, diffs). Faça referência a eles pelo caminho ou pela URL.

Redija qualquer informação sensível, como chaves de API, senhas ou dados pessoais identificáveis.

Se o usuário passar argumentos, trate-os como a descrição do foco da próxima sessão e adapte o documento a isso.
