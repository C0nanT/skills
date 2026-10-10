```yaml
name: claude-handoff
description: Passe a conversa atual para um agente novo em segundo plano, que assume o trabalho imediatamente.
argument-hint: "Para que a próxima sessão será usada?"
disable-model-invocation: true
```

Escreva um resumo de handoff da conversa atual, para que um agente novo possa continuar o trabalho. Salve-o no diretório temporário do sistema operacional do usuário e, em seguida, inicie um agente em segundo plano que receba esse resumo como prompt: `claude --bg --name "<nome descritivo>" -- "$(cat <arquivo do resumo>)"`. Passar o arquivo impede o shell de executar crases ou expandir `$` dentro do resumo. O agente começa no diretório de trabalho atual e retorna imediatamente; o usuário o gerencia com `claude agents`.

Sempre passe `-n`/`--name` com um nome descritivo (por exemplo, `--name "Fix login bug"`); ele define o nome de exibição mostrado na lista de jobs, no seletor de sessões e no título do terminal.

Inclua no resumo uma seção "suggested skills", indicando quais skills o próximo agente deve chamar com a ferramenta Skill.

Não repita conteúdo já registrado em outros artefatos (especificações, planos, ADRs, issues, commits, diffs). Faça referência a eles pelo caminho ou pela URL.

Redija qualquer informação sensível, como chaves de API, senhas ou dados pessoais identificáveis, já que o resumo se torna o prompt do agente.

Se o usuário passar argumentos, trate-os como a descrição do foco da próxima sessão e adapte o resumo a isso.
