```yaml
name: prototype
description: Construa um protótipo descartável para responder a uma pergunta de design. Use quando o usuário quiser verificar se um modelo de estados ou uma lógica parece correto, ou explorar como uma UI deveria ser.
```

# Protótipo

Um protótipo é **código descartável que responde a uma pergunta**. A pergunta define a forma do protótipo.

## Escolha um branch

Identifique qual pergunta está sendo respondida, usando o prompt do usuário, o código ao redor ou perguntando, caso o usuário esteja disponível:

- **"Esta lógica / modelo de estados parece correto?"** → [LOGIC.pt-BR.md](LOGIC.pt-BR.md). Construa um único arquivo HTML compartilhável (botões de livre exploração mais passos guiados em abas) que leve a máquina de estados por casos difíceis de raciocinar só no papel, e que uma pessoa não desenvolvedora consiga conduzir.
- **"Como isto deveria ser visualmente?"** → [UI.pt-BR.md](UI.pt-BR.md). Gere várias variações de UI radicalmente diferentes em uma única rota, alternáveis por um parâmetro de busca na URL e uma barra flutuante inferior.

Os dois branches produzem artefatos muito diferentes, então errar a escolha desperdiça o protótipo inteiro. Se a pergunta for genuinamente ambígua e o usuário não puder ser consultado, use o branch que combine melhor com o código ao redor (um módulo de backend → lógica; uma página ou componente → UI) e declare a suposição no topo do protótipo.

## Regras que valem para os dois

1. **Descartável desde o primeiro dia, e claramente marcado como tal.** Coloque o código do protótipo perto de onde ele será de fato usado (ao lado do módulo ou da página que ele prototipa), para que o contexto fique óbvio, mas dê a ele um nome que deixe claro para qualquer leitor que é um protótipo, e não código de produção. Para rotas de UI descartáveis, siga a convenção de rotas que o projeto já usa; não invente uma nova estrutura de topo.
2. **Fácil de executar.** Um protótipo de UI começa com um único comando do task runner do projeto: `pnpm <nome>`, `python <caminho>`, `bun <caminho>` etc. Uma demo de lógica é um único arquivo HTML que o usuário abre com dois cliques. Em ambos os casos, nenhum esforço para começar.
3. **Sem persistência por padrão.** O estado fica na memória. A persistência é justamente o que o protótipo está _verificando_, não algo do qual ele deve depender. Se a pergunta envolver explicitamente um banco de dados, use um banco de testes ou um arquivo local com um nome claro do tipo "PROTOTYPE, wipe me".
4. **Dispense o acabamento.** Sem testes, sem tratamento de erros além do necessário para torná-lo _executável_, sem abstrações. O objetivo é aprender algo rápido.
5. **Mostre o estado.** Depois de cada ação (lógica) ou a cada troca de variação (UI), imprima ou renderize o estado completo relevante para que o usuário veja o que mudou.
6. **Registre ao terminar.** Incorpore as decisões validadas ao código real e, em seguida, registre o próprio protótipo como **fonte primária**: faça commit dele em um branch descartável, fora da main, e deixe uma referência de contexto para esse branch na issue de implementação. Registre também a resposta (o veredito e a pergunta que ele resolveu) na issue ou em um commit. A branch main mantém apenas a decisão validada.
