```yaml
name: retro
description: "Conduza uma retrospectiva de uma sessão de código."
disable-model-invocation: true
```

O usuário pediu uma **retrospectiva**. Você está sugerindo melhorias no **ambiente** do agente de código, para que as próximas execuções sejam melhores.

## Passos

1. Chame a ferramenta Skill com `writing-for-agents` para obter o guia de estilo de escrita.

2. Leia as fontes primárias da sessão que o usuário indicar. Isso pode exigir pesquisar nos logs de sessão desta máquina. Se o usuário não indicar uma sessão, use a atual por padrão.

3. Procure candidatos a melhoria nestas categorias.

- **Navegação**: quão fácil foi para o agente encontrar os arquivos certos? Há dependências ocultas entre arquivos? Um **ponteiro de navegação** ajudaria? _Use quando_ a sessão levou muito tempo para encontrar uma informação.
- **Checagens automatizadas**: existem checagens automáticas que poderiam pegar erros cometidos pelo agente? Linting, tipagem, testes, linters de sistema de arquivos? Leia primeiro o comando de checagem do próprio repositório (seus scripts `lint`/`check` no `package.json` ou na ferramenta de build, seu workflow de CI), para que uma checagem que já existe, mas não está conectada ou está silenciosamente quebrada, seja o achado, e não uma reinvenção. Um repositório sem nenhum **guardrail** (sem hook de pre-commit e sem job de CI que rode seu comando de lint, typecheck ou testes) já é um achado em si: um repositório sem lint é uma oportunidade perdida permanente, não um padrão neutro. _Use quando_ o agente cometeu um erro que uma checagem automatizada poderia ter pego, ou quando o repositório não tem nenhum guardrail.
- **Padrões de código**: o **agente revisor** deve receber uma nova regra para aplicar? Alguma regra existente deve ser removida ou esclarecida? Primeiro classifique a violação. Uma violação **mecânica** (um padrão sintático fixo, uma API proibida, um formato de import, uma regra de localização de arquivo) recebe uma checagem determinística, sem discussão: uma regra customizada no linter do próprio repositório, um novo hook de pre-commit ou um novo job de CI, o que for mais barato dado a linguagem do repositório e o guardrail existente. Por padrão, prefira construir a checagem a escrever a regra. Reserve `CODING_STANDARDS.md` para **julgamentos** genuínos (consistência entre arquivos, "combina com o estilo ao redor", qualquer coisa que nenhum guardrail poderia substituir). _Use quando_ o agente revisor deixou passar um erro.
- **AGENTS.md global**: alguma instrução de direcionamento deveria virar padrão de código (ou checagem automatizada)? _Use quando_ o arquivo AGENTS.md estiver particularmente grande, seja no repositório, seja no escopo global do usuário.
- **Economia de ferramentas**: o agente fez chamadas de ferramenta caras que poderiam ser simplificadas? Há alguma ferramenta customizada (CLIs, MCPs) particularmente ineficiente em tokens? _Use quando_ o agente fez uma chamada de ferramenta cara.
- **Não operações**: procure instruções nos arquivos de direcionamento que não alteram o comportamento do agente. _Use quando_ os arquivos de direcionamento estiverem grandes e difíceis de manejar.
- **Acesso à informação**: procure oportunidades de dar ao agente mais acesso a informações. Por exemplo, direcionar os logs do servidor de desenvolvimento para ele, ou dar acesso somente leitura a serviços de terceiros. _Use quando_ uma informação crucial não estava disponível para o agente.

1. Apresente esses candidatos ao usuário, em ordem de gravidade.

## Referência

### Implementação versus revisão

Lembre-se de que todo trabalho passa por duas etapas: implementação e revisão. O agente de implementação é o que mais sofre **pressão de contexto**. Ele é responsável pela exploração, pela escrita de código e pela depuração de falhas.

O agente de revisão sofre a menor pressão de contexto: ele recebe um diff, então não precisa explorar. Muitas vezes também não precisa escrever código nem depurar.

Isso significa que o agente de revisão deve ser responsável por impor os padrões de código, e não o agente de implementação.

### Arquivos

Você tem acesso a vários arquivos no repositório:

- `CLAUDE.md`/`AGENTS.md`: esses arquivos são empurrados para a janela de contexto de qualquer agente que trabalhe neste repositório. Devem ser usados com extrema parcimônia, geralmente apenas para **ponteiros de navegação** para outros arquivos.
- `CODING_STANDARDS.md`: esse arquivo é lido durante a revisão, não durante a implementação. Adicione **ponteiros de navegação** para pastas de documentação se o arquivo de padrões passar de 1.000 linhas.
- Documentação: use a documentação como arquivos de referência, apontados por outros arquivos. Procure documentação existente antes de escrever uma nova.
- Skills: use skills para documentação (já que a descrição delas entra na janela de contexto do agente), ou para comandos invocados pelo usuário. Siga as orientações da skill `writing-for-agents`.
