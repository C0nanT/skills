```yaml
name: setup-solid
description: Escreve uma seção SOLID no nível de arquitetura no CLAUDE.md deste repositório, delimitada pela regra do escoteiro. Rode uma vez por repositório.
disable-model-invocation: true
```

# Configurar SOLID

Instale uma instrução durável no repositório: **aplique SOLID no nível de arquitetura, pela regra do escoteiro.**

A **regra do escoteiro** (boy scout rule) é todo o sentido desta configuração. SOLID se aplica ao código que está sendo escrito agora e ao código que o fluxo atual já atravessa, nunca ao repositório como um todo. A base de código converge uma mudança por vez.

A seção é **independente de linguagem**: ela fala de módulos, seams e direção de dependência, não do container de injeção de dependência de um framework nem da palavra-chave `interface` de uma linguagem. O que a torna valiosa é a exploração do passo 1, porque a seção nomeia os caminhos e as camadas *reais* deste repositório.

A seção é sempre escrita em **inglês**, como o restante dos padrões de código, seja qual for o idioma da prosa do repositório.

## Processo

### 1. Explore

Leia o repositório antes de rascunhar. Não presuma:

- Linguagens e como o código é agrupado: pacotes, pastas, serviços. Quais pastas guardam a **política** (domínio / regras de negócio) e quais guardam os **detalhes** (banco de dados, HTTP, SDKs, sistema de arquivos)?
- `CLAUDE.md` e `AGENTS.md` na raiz: algum deles existe? Um é um link simbólico para o outro? Já existe uma seção SOLID (em qualquer nível de título ou capitalização), ou uma seção de arquitetura / padrões de código que se sobreponha a ela?
- Sinais de monorepo: `pnpm-workspace.yaml`, um campo `workspaces` no `package.json`, um `packages/*` preenchido com arquivos `CLAUDE.md` por pacote. Só importa se os pacotes tiverem layouts de camadas *genuinamente diferentes*; caso contrário, o arquivo da raiz cobre todos eles.
- `GLOSSARY.md`: o vocabulário de domínio que a seção deve usar para os conceitos deste repositório.
- ADRs (`.agents/adr/`, `docs/adr/`): decisões de arquitetura que a seção não pode contradizer.
- Como as dependências já são injetadas (argumentos de construtor, parâmetros de função, um container, imports de módulo) e como os testes já as substituem: a seção deve descrever a convenção que existe, não importar uma nova.

Pronto quando você conseguir nomear, nos caminhos do próprio repositório, onde mora a política, onde moram os detalhes, como os dois estão conectados hoje e como um teste substitui um detalhe.

**Quando não há divisão entre política e detalhes, pare.** Um repositório de documentação, um repositório só de scripts pequenos, um repositório de arquivos de prompt: nada ali tem uma fronteira de IO para a seção moldar. Diga ao usuário que o repositório não tem camadas que esta seção possa nomear, e não a escreva. Se a divisão existir mas for fraca (uma pasta de domínio pequena, sem interfaces ainda), ofereça a seção reduzida: apenas SRP e OCP, sem o bloco `### In this repo`, e diga o que deixou de fora.

### 2. Rascunhe e confirme

Mostre ao usuário a seção completa que pretende escrever, com os marcadores preenchidos a partir do passo 1. Pergunte apenas o que de fato ramifica:

- Em qual arquivo escrever, **somente** quando não existirem nem `CLAUDE.md` nem `AGENTS.md`.
- Qualquer coisa que a exploração deixou ambígua: por exemplo, duas pastas de política plausíveis.

Aponte, em vez de resolver em silêncio:

- **Uma seção de padrões sobreposta.** Se uma seção de arquitetura ou de padrões de código já decide sobre a direção de dependência ou a abstração, diga isso e proponha ou incorporar o SOLID nela, ou fazer o SOLID delegar a ela. Duas séries de regras sobre a mesma questão no mesmo arquivo é pior do que nenhuma: o `/review-axes` lê as duas como padrões documentados.
- **Um conflito com ADR.** Se um ADR contradiz um princípio, nomeie o ADR e o item. Não descarte o princípio em silêncio; um item de DIP que sumiu é um buraco sem explicação.

Deixe o usuário editar o rascunho antes de você escrever.

### 3. Escreva

Escolha o arquivo: edite o `CLAUDE.md` se ele existir; senão o `AGENTS.md`; senão o que o usuário escolheu. Nunca crie o outro quando um já existir, e quando um for um link simbólico para o outro, escrever por qualquer um dos dois é escrever nos dois: escolha um e não toque no segundo caminho.

Se já existir uma seção SOLID, em qualquer nível de título ou capitalização: atualize-a no lugar em vez de acrescentar uma segunda. Deixe as demais seções intactas.

A seção:

```markdown
## SOLID

Apply SOLID at the **architecture** level: module boundaries, dependency direction, and the interfaces between them. It is a way to shape seams, not a naming ritual. "Module" means whatever this codebase groups behaviour into: a class, a package, a file of functions, a service.

### Scope: boy scout rule

SOLID applies to:

- code written new in the current change, and
- the existing code the current flow already passes through, when a small local edit clears friction that change is hitting.

The rest of the codebase stays as it is. Keep a change's blast radius on the flow being built or fixed: a repo-wide SOLID refactor is its own piece of work, and happens only when explicitly asked for. The codebase converges one change at a time.

When applying a principle would require reshaping modules outside the current flow, leave them alone and say so in the summary of the change.

### In this repo

- **Policy**: [POLICY PATHS]
- **Details**: [DETAILS PATHS]
- **Wiring**: [INJECTION CONVENTION]
- **Test substitution**: [TEST SUBSTITUTION CONVENTION]

### The principles, as architecture rules

- **SRP**: a module has one reason to change. When one flow forces edits in a module that other flows also own for unrelated reasons, that module is holding two responsibilities.
- **OCP**: new behaviour arrives as a new implementation behind an existing interface, rather than another branch in a growing conditional over kinds of thing.
- **LSP**: every implementation of an interface is substitutable through that interface: same contract, same error behaviour, no "this one also needs X called first".
- **ISP**: a consumer depends on the narrow interface it actually uses. Interfaces are shaped by the caller's need, not by everything the implementation can do.
- **DIP**: policy does not depend on details (see *In this repo* above for both). The interface belongs to the policy side; the detail implements it and is passed in.

### Applying it

- When a new flow crosses an IO boundary, define the interface from the policy side and inject the implementation.
- One production implementation is enough **when a test substitutes it**: the test double is the second implementation, and the interface is the test surface. An adapter behind an interface with a single caller and no substitution is a hypothetical seam: drop the interface until something real needs it.
- Use this repo's domain vocabulary (`GLOSSARY.md`) when naming modules and interfaces.
```

Preencha `[POLICY PATHS]`, `[DETAILS PATHS]`, `[INJECTION CONVENTION]` e `[TEST SUBSTITUTION CONVENTION]` com os caminhos e as convenções reais deste repositório, obtidos no passo 1: globs concretos (`src/domain/**`), não categorias. Remova a linha do `GLOSSARY.md` quando o repositório não tiver esse arquivo. Quando um ADR sobrepuser um princípio, mantenha o item e acrescente a exceção no próprio texto, citando o ADR.

Depois, releia o que escreveu e confira: nenhum `[PLACEHOLDER]` sobreviveu, e existe exatamente uma seção SOLID no arquivo. Um marcador que sobra vira ruído permanente para toda skill que leia esse arquivo depois.

### 4. Pronto

Diga ao usuário:

- Qual arquivo você editou.
- Que o SOLID agora se aplica ao código novo e ao código que cada mudança já toca: nenhuma passada de refatoração separada está por vir.
- **Que isso mudou o comportamento de outras skills.** O `/review-axes` trata um padrão documentado do repositório como vencendo a própria linha de base, então, daqui para frente, ele aponta diffs que quebram estes itens, citando esta seção; o `/implement` os lê ao escrever código. Se isso for mais rígido do que eles querem, este é o momento de suavizar um item.

Rodar esta skill de novo só é necessário para remodelar a própria seção; editá-la diretamente também está bem.
