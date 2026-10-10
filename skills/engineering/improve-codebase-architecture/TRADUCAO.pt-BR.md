```yaml
name: improve-codebase-architecture
description: Varra uma base de código em busca de oportunidades de aprofundamento, apresente-as como um relatório HTML visual e depois faça um grilling sobre a que você escolher.
disable-model-invocation: true
```

# Melhorar a arquitetura da base de código

Revele o atrito arquitetural e proponha **oportunidades de aprofundamento**: refatorações que transformam módulos rasos em módulos profundos. O objetivo é testabilidade e navegabilidade para IA.

Este comando é _informado_ pelo modelo de domínio do projeto e se apoia em um vocabulário de design compartilhado:

- Use um vocabulário arquitetural preciso (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) e seus princípios (o teste de deleção, "a interface é a superfície de teste", "um adapter = seam hipotético, dois = seam real"). Use esses termos exatamente em cada sugestão: não escorregue para "component", "service", "API" ou "boundary".
- Um **test double conta como segunda implementação**: uma interface com um único adapter de produção que um teste substitui é um seam real, e não um seam hipotético. Só uma interface com um único chamador e _nenhuma_ substituição falha no teste de deleção por esse critério. (Esta é a mesma regra que o `/setup-solid` escreve no `CLAUDE.md`; as duas não podem divergir.)
- O vocabulário de domínio do `GLOSSARY.md` dá nomes aos bons seams; os ADRs em `docs/adr/` registram decisões que este comando não deve rediscutir.

## Processo

### 1. Explorar

**Defina o escopo antes de varrer: YAGNI.** Aprofundar um módulo compensa ao tornar mais fáceis as mudanças futuras nele, então dê peso extra às partes da base de código que mudaram recentemente. Decida _onde_ procurar antes de procurar:

- Se o usuário indicou uma direção (um módulo, um subsistema, um ponto de dor), siga-a e pule a inferência abaixo.
- Caso contrário, percorra um bom trecho do histórico de commits (`git log --oneline`) para encontrar os pontos quentes da base de código, os arquivos e áreas que aparecem sempre, e deixe esses caminhos atrair sua atenção primeiro. Se as mudanças estiverem espalhadas sem um ponto quente claro, amplie a busca.

Leia primeiro o glossário de domínio do projeto (`GLOSSARY.md`) e os ADRs da área que você está tocando.

Depois, crie um subagente para percorrer a base de código. Não siga heurísticas rígidas; explore de forma orgânica e anote onde sentir atrito:

- Onde entender um conceito exige pular entre muitos módulos pequenos?
- Onde os módulos são **rasos**, com uma interface quase tão complexa quanto a implementação?
- Onde funções puras foram extraídas só para testabilidade, mas os bugs reais se escondem em como elas são chamadas (sem **locality**)?
- Onde módulos fortemente acoplados vazam pelos seus seams?
- Quais partes da base de código não têm testes, ou são difíceis de testar pela interface atual?

Aplique o **teste de deleção** a tudo que você suspeitar ser raso: apagar isso concentraria a complexidade, ou apenas a moveria? Um "sim, concentra" é o sinal que você quer.

### 2. Apresentar os candidatos como um relatório HTML

Escreva um arquivo HTML autocontido no diretório temporário do sistema operacional, para que nada seja gravado no repositório. Resolva o diretório temporário a partir de `$TMPDIR`, com `/tmp` como alternativa (ou `%TEMP%` no Windows), e grave em `<tmpdir>/architecture-review-<timestamp>.html`, para que cada execução gere um arquivo novo. Abra-o para o usuário (`xdg-open <caminho>` no Linux, `open <caminho>` no macOS, `start <caminho>` no Windows) e informe o caminho absoluto.

O relatório usa **Tailwind via CDN** para layout e estilo, e **Mermaid via CDN** para diagramas em que um grafo, fluxo ou sequência comunica bem a estrutura. Combine o Mermaid com visuais em CSS/SVG feitos à mão: use o Mermaid quando as relações tiverem formato de grafo (grafos de chamadas, dependências, sequências), e divs/SVG construídos à mão quando quiser algo mais editorial (diagramas de massa, cortes transversais, animações de recolhimento). Cada candidato recebe uma **visualização antes/depois**. Seja visual.

Para cada candidato, renderize um cartão com:

- **Arquivos**: quais arquivos/módulos estão envolvidos
- **Problema**: por que a arquitetura atual causa atrito
- **Solução**: descrição em linguagem simples do que mudaria
- **Benefícios**: explicados em termos de locality e leverage, e de como os testes melhorariam
- **Diagrama antes / depois**: lado a lado, desenhado sob medida, ilustrando a superficialidade e o aprofundamento
- **Força da recomendação**: um dos valores `Strong`, `Worth exploring`, `Speculative`, renderizado como um selo

Termine o relatório com uma seção **Top recommendation**: qual candidato você atacaria primeiro e por quê.

**Use o vocabulário do GLOSSARY.md para o domínio, e o vocabulário arquitetural acima para a arquitetura.** Se o `GLOSSARY.md` define "Order", fale em "o módulo de entrada de Order", não em "o FooBarHandler", e não em "o serviço de Order".

**Conflitos com ADRs**: se um candidato contradiz um ADR existente, só o apresente quando o atrito for real o bastante para justificar reabrir o ADR. Marque isso claramente no cartão (por exemplo, um callout de aviso: _"contradicts ADR-0007, but worth reopening because…"_). Não liste toda refatoração teórica que um ADR proíba.

Veja [HTML-REPORT.pt-BR.md](HTML-REPORT.pt-BR.md) para o esqueleto HTML completo, os padrões de diagrama e as orientações de estilo.

NÃO proponha interfaces ainda. Depois que o arquivo for gravado, pergunte ao usuário: "Which of these would you like to explore?"

### 3. Laço de grilling

Quando o usuário escolher um candidato, chame a ferramenta Skill com "grilling" para percorrer a árvore de decisões com ele: restrições, dependências, o formato do módulo aprofundado, o que fica atrás do seam e quais testes sobrevivem.

Efeitos colaterais acontecem em linha, à medida que as decisões se consolidam: mantenha o modelo de domínio atualizado conforme avança:

- **Vai nomear um módulo aprofundado com um conceito que não está no `GLOSSARY.md`?** Acrescente o termo ao `GLOSSARY.md`. Crie o arquivo de forma preguiçosa, apenas se ele ainda não existir.
- **Refinou um termo vago durante a conversa?** Atualize o `GLOSSARY.md` ali mesmo.
- **O usuário rejeita o candidato por um motivo que sustenta a decisão?** Ofereça um ADR, enquadrado assim: _"Quer que eu registre isto como ADR para que as próximas revisões de arquitetura não o sugiram de novo?"_ Ofereça só quando o motivo for realmente necessário para que um futuro explorador não sugira a mesma coisa de novo; pule motivos efêmeros ("não vale a pena agora") e os que são autoevidentes.
- **Quer explorar interfaces alternativas para o módulo aprofundado?** Use a abordagem de projetar duas vezes: crie subagentes paralelos para rascunhar interfaces alternativas e depois compare-as.
