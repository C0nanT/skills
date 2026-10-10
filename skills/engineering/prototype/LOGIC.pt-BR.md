# Protótipo de lógica

Um único arquivo HTML autocontido (uma **demo compartilhável**) que permite a qualquer pessoa conduzir um modelo de estados clicando em botões. Use isto quando a pergunta for sobre **lógica de negócio, transições de estado ou formato de dados**: o tipo de coisa que parece razoável no papel, mas só mostra que está errada quando passa por casos reais.

Como é um arquivo só, sem nada para instalar, você pode entregá-lo a alguém que não é desenvolvedor (um designer, um PM, um especialista do domínio) e deixá-lo sentir o modelo por conta própria. Por isso ele fala a linguagem dessa pessoa, e não a do código.

## Quando este é o formato certo

- "Não tenho certeza se esta máquina de estados trata o caso de borda em que X e depois Y."
- "Este modelo de dados realmente me deixa representar o caso em que..."
- "Quero sentir como a API deveria ser antes de escrevê-la."
- Qualquer situação em que alguém queira **apertar botões e ver o estado mudar**.

Se a pergunta for "como isto deveria parecer", este é o branch errado. Use [UI.pt-BR.md](UI.pt-BR.md).

## Processo

### 1. Enuncie a pergunta

Antes de escrever código, escreva qual modelo de estado e qual pergunta você está prototipando. Um parágrafo, no topo da demo (em uma introdução visível, não só em um comentário). Um protótipo de lógica que responde à pergunta errada é puro desperdício, então deixe a pergunta explícita para que ela possa ser conferida depois, quer o usuário esteja olhando agora, quer esteja voltando depois, longe do teclado.

### 2. Isole a lógica em um módulo portátil

Coloque a lógica de fato (a parte que responde à pergunta) em um único bloco `<script>`, escrito como um pequeno módulo puro que pudesse ser retirado e colocado no código real mais tarde. A página em volta é descartável; este módulo não é.

A forma certa depende da pergunta:

- **Um reducer puro**: `(state, action) => state`. Bom quando as ações são eventos discretos e o estado é um único valor.
- **Uma máquina de estados**: estados e transições explícitos. Bom quando "quais ações são legais agora" faz parte da pergunta.
- **Um pequeno conjunto de funções puras** sobre um tipo de dado simples. Bom quando não há estado atual implícito, apenas transformações.
- **Uma classe ou módulo com superfície de métodos clara**, quando a lógica realmente tem estado interno contínuo.

Escolha a forma que melhor se encaixa na pergunta feita, _não_ a que é mais fácil de conectar a uma página. Mantenha-o puro: sem DOM, sem `document`, sem handlers de botão mexendo lá dentro. A página chama o módulo; nada flui na direção oposta. É isso que faz o protótipo ser útil depois da própria vida útil: uma vez respondida a pergunta, o conjunto validado de reducer / máquina / funções sobe para o módulo real por conta própria.

### 3. Construa o arquivo HTML compartilhável

Um arquivo só, HTML/CSS/JS puro: sem framework, sem bundler, sem servidor, tudo inline, para que abra com duplo clique e sobreviva a ser enviado por e-mail. Qualquer pessoa deve conseguir rodá-lo apenas abrindo-o.

Escreva para um não desenvolvedor. Todo rótulo está na **linguagem do domínio**, não na do código: botões e estados falam como o negócio, não como o reducer. Explique em palavras simples o que está acontecendo.

Organize o layout com uma hierarquia limpa, de cima para baixo:

1. **Título e uma linha de explicação** do que esta demo permite explorar (a pergunta do passo 1).
2. **Estado atual**: o estado completo relevante, renderizado como um painel legível (campos rotulados, não um despejo bruto de JSON), redesenhado após cada clique para que a mudança fique visível. Quando ajudar um não desenvolvedor a acompanhar, destaque o que acabou de mudar.
3. **Botões de livre exploração**: um botão por ação, sempre disponíveis, para que qualquer pessoa possa cutucar o modelo em qualquer ordem. Cada clique despacha a ação e redesenha o estado.
4. **Percursos guiados**: um conjunto de **cenários**, um por aba. Cada aba traz uma descrição curta, em linguagem simples, do cenário (a situação que ele monta e o que observar), e logo abaixo, os **botões a pressionar**, em ordem, para aquele cenário. Cada passo é um botão de verdade: clicar nele executa aquela ação e avança para o próximo passo. Iniciar um percurso restaura um estado inicial conhecido, para que o cenário se comporte sempre do mesmo jeito.

Escolha cenários que demonstrem os casos incômodos, aqueles difíceis de raciocinar no papel: o caminho feliz, um caso de borda complicado, uma tentativa de algo que deveria ser ilegal.

Mantenha bonito, mas contido: tipografia limpa, espaçamento generoso, uma cor de destaque. Sem animações, sem firulas: nada que concorra com o estado e os botões.

### 4. Entregue

Envie o arquivo para a pessoa, ou abra-o para ela. Ela vai percorrer os percursos e a livre exploração quando tiver tempo; os momentos interessantes são quando ela diz "espera, isso não deveria ser possível" ou "hum, eu achei que X seria diferente": esses são os bugs na _ideia_, que é exatamente o objetivo. Se ela quiser novas ações ou um novo cenário, adicione. Protótipos evoluem.

### 5. Registre a resposta e o protótipo

Quando o protótipo tiver respondido à pergunta, registre a resposta e, em seguida, registre o protótipo do jeito que o [SKILL](TRADUCAO.pt-BR.md) descreve. O mapeamento específico da lógica: o conjunto validado de reducer / máquina / funções sobe para o módulo real (a decisão, absorvida); a casca HTML vai junto para o branch descartável que guarda o protótipo como fonte primária e, por ser um arquivo autocontido, continua trivialmente executável ali.

## Anti-padrões

- **Não adicione testes.** Um protótipo que precisa de testes deixou de ser protótipo.
- **Não conecte ao banco de dados real.** Use estado em memória, a menos que a pergunta seja especificamente sobre persistência.
- **Não generalize.** Nada de "e se quiséssemos suportar X depois". O protótipo responde a uma pergunta.
- **Não misture a lógica com a página.** Se o módulo puro referenciar o DOM, `document` ou handlers de botão, ele deixou de poder ser retirado. Mantenha a página como uma casca fina sobre um módulo puro.
- **Não recorra a framework, bundler ou servidor.** Um arquivo que o destinatário abre com duplo clique; um app React ou um servidor de desenvolvimento anula o "compartilhável".
- **Não envie a casca HTML para produção.** A página é otimizada para ser clicada à mão. O módulo de lógica por trás dela é a parte que vale a pena manter.
