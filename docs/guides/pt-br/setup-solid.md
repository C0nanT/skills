# Setup SOLID

> Tradução em português da skill [`setup-solid`](../../../skills/engineering/setup-solid/SKILL.md). O conteúdo é o mesmo do `SKILL.md`; a skill que o agente executa é a versão em inglês.

Instala uma instrução duradoura no repositório: **aplique SOLID no nível de arquitetura, seguindo a boy scout rule.**

A **boy scout rule** é o ponto central deste setup. SOLID incide sobre o código que está sendo escrito agora e sobre o código pelo qual o fluxo atual já passa — nunca sobre o repositório inteiro. O codebase converge uma mudança por vez.

A seção é **agnóstica de linguagem**: fala em módulos, seams e direção de dependência, não no container de DI de um framework ou na palavra-chave `interface` de uma linguagem. O que a torna útil é a exploração da etapa 1 — a seção nomeia as camadas e caminhos reais *deste* repositório.

A seção é sempre escrita em **inglês**, como o resto dos padrões de código, qualquer que seja o idioma da prosa do repo.

## Processo

### 1. Explorar

Leia o repositório antes de rascunhar. Não presuma:

- Linguagens e como o código é agrupado — pacotes, pastas, serviços. Quais pastas guardam **policy** (domínio / regras de negócio) e quais guardam **details** (banco, HTTP, SDKs, filesystem)?
- `CLAUDE.md` e `AGENTS.md` na raiz — algum deles existe? Um é symlink do outro? Já há uma seção SOLID (em qualquer nível de heading ou caixa), ou uma seção de arquitetura / padrões de código que se sobreponha a ela?
- Sinais de monorepo — `pnpm-workspace.yaml`, um campo `workspaces` no `package.json`, um `packages/*` populado com `CLAUDE.md` por pacote. Só importa se os pacotes têm layouts de camada *genuinamente diferentes*; senão o arquivo da raiz cobre todos.
- `CONTEXT.md` — o vocabulário de domínio que a seção deve usar para os conceitos deste repo.
- ADRs (`.agents/adr/`, `docs/adr/`) — decisões de arquitetura que a seção não pode contradizer.
- Como as dependências já são injetadas hoje (argumentos de construtor, parâmetros de função, um container, imports de módulo) e como os testes já as substituem — a seção deve descrever a convenção que existe, não importar uma nova.

Concluído quando você conseguir nomear, nos caminhos reais deste repo, onde mora a policy, onde moram os details, como os dois estão ligados hoje, e como um teste substitui um detail.

**Quando não existe divisão policy/details, pare.** Um repo de docs, um repo fino de scripts, um repo de arquivos de prompt — nada ali tem fronteira de IO para moldar. Diga ao usuário que o repo não tem camadas para esta seção nomear, e não a escreva. Se a divisão existe mas é fina (uma pasta de domínio pequena, nenhuma interface ainda), ofereça a seção reduzida: só SRP e OCP, sem o bloco `### In this repo`, e diga o que foi removido.

### 2. Rascunhar e confirmar

Mostre ao usuário a seção completa que você pretende escrever, com os marcadores preenchidos a partir da etapa 1. Pergunte apenas o que realmente bifurca:

- Em qual arquivo escrever, **somente** quando nem `CLAUDE.md` nem `AGENTS.md` existirem.
- Qualquer coisa que a exploração tenha deixado ambígua — por exemplo, duas pastas plausíveis para a policy.

Traga à tona, em vez de resolver silenciosamente:

- **Uma seção de padrões que se sobrepõe.** Se já existe uma seção de arquitetura ou de padrões de código que decide sobre direção de dependência ou abstração, diga isso e proponha ou fundir SOLID nela, ou fazer SOLID deferir a ela. Dois conjuntos de regras sobre a mesma questão no mesmo arquivo é pior que nenhum — `/review-axes` lê os dois como padrões documentados.
- **Um conflito com ADR.** Se um ADR contradiz um princípio, nomeie o ADR e o bullet. Não remova o princípio em silêncio; um bullet de DIP faltando é um buraco inexplicado.

Deixe o usuário editar o rascunho antes de você escrever.

### 3. Escrever

Escolha o arquivo: edite o `CLAUDE.md` se ele existir; senão o `AGENTS.md`; senão o que o usuário escolheu. Nunca crie um deles quando o outro já está lá — e quando um é symlink do outro, escrever por qualquer um escreve nos dois, então escolha um e não toque no segundo caminho.

Se já existir uma seção SOLID — em qualquer nível de heading ou caixa — atualize-a no lugar em vez de acrescentar uma segunda. Deixe as seções ao redor intactas.

A seção (escrita em inglês):

```markdown
## SOLID

Apply SOLID at the **architecture** level — module boundaries, dependency direction, and the interfaces between them. It is a way to shape seams, not a naming ritual. "Module" means whatever this codebase groups behaviour into: a class, a package, a file of functions, a service.

### Scope — boy scout rule

SOLID applies to:

- code written new in the current change, and
- the existing code the current flow already passes through, when a small local edit clears friction that change is hitting.

The rest of the codebase stays as it is. Keep a change's blast radius on the flow being built or fixed — a repo-wide SOLID refactor is its own piece of work, and happens only when explicitly asked for. The codebase converges one change at a time.

When applying a principle would require reshaping modules outside the current flow, leave them alone and say so in the summary of the change.

### In this repo

- **Policy** — [POLICY PATHS]
- **Details** — [DETAILS PATHS]
- **Wiring** — [INJECTION CONVENTION]
- **Test substitution** — [TEST SUBSTITUTION CONVENTION]

### The principles, as architecture rules

- **SRP** — a module has one reason to change. When one flow forces edits in a module that other flows also own for unrelated reasons, that module is holding two responsibilities.
- **OCP** — new behaviour arrives as a new implementation behind an existing interface, rather than another branch in a growing conditional over kinds of thing.
- **LSP** — every implementation of an interface is substitutable through that interface: same contract, same error behaviour, no "this one also needs X called first".
- **ISP** — a consumer depends on the narrow interface it actually uses. Interfaces are shaped by the caller's need, not by everything the implementation can do.
- **DIP** — policy does not depend on details (see *In this repo* above for both). The interface belongs to the policy side; the detail implements it and is passed in.

### Applying it

- When a new flow crosses an IO boundary, define the interface from the policy side and inject the implementation.
- One production implementation is enough **when a test substitutes it** — the test double is the second implementation, and the interface is the test surface. An adapter behind an interface with a single caller and no substitution is a hypothetical seam: drop the interface until something real needs it.
- Use this repo's domain vocabulary (`CONTEXT.md`) when naming modules and interfaces.
```

Preencha `[POLICY PATHS]`, `[DETAILS PATHS]`, `[INJECTION CONVENTION]` e `[TEST SUBSTITUTION CONVENTION]` com os caminhos e convenções reais deste repo, vindos da etapa 1 — globs concretos (`src/domain/**`), não categorias. Remova a linha do `CONTEXT.md` quando o repo não tiver esse arquivo. Onde um ADR sobrepõe um princípio, mantenha o bullet e acrescente a exceção inline, citando o ADR.

Depois releia o que você escreveu e confira: nenhum `[PLACEHOLDER]` sobreviveu, e existe exatamente uma seção SOLID no arquivo. Um marcador esquecido vira ruído permanente para toda skill que ler esse arquivo depois.

### 4. Concluído

Diga ao usuário:

- Qual arquivo você editou.
- Que SOLID agora se aplica a código novo e ao código que cada mudança já toca — nenhuma passada de refatoração separada está por vir.
- **Que isso mudou o comportamento de outras skills.** `/review-axes` trata um padrão documentado do repo como vencedor sobre o próprio baseline dela, então de agora em diante ela sinaliza diffs que quebram estes bullets, citando esta seção; `/implement` os lê ao escrever código. Se isso for mais estrito do que ele quer, este é o momento de afrouxar um bullet.

Re-rodar esta skill só é necessário para remodelar a própria seção; editá-la diretamente está ok.
