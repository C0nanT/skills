# conan-skills

Coleção de agent skills (comandos `/slash`) para Claude Code. Fork do [repositório do Matt Pocock](https://github.com/mattpocock/skills).

## Instalar

```bash
npx skills@latest add C0nanT/skills
```

### Hooks (caveman + git guardrails)

Requer as skills instaladas. Gerenciado pelo [claude-hooks](https://github.com/C0nanT/claude-hooks):

```bash
npx @c0nant/claude-hooks install
```

Instala dois hooks no `~/.claude/settings.json`:

- **caveman** (`SessionStart`) — modo caveman automático em toda sessão
- **git-guardrails** (`PreToolUse/Bash`) — bloqueia git destrutivo antes de executar

## Desinstalar

```bash
npx @c0nant/claude-hooks uninstall
```

## Por que estas skills existem

Adaptei este fork para corrigir modos de falha comuns que vejo com Claude Code, Codex e outros agentes de código.

### #1: O agente não fez o que eu queria

> "No-one knows exactly what they want"
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**O problema**. O modo de falha mais comum em desenvolvimento de software é desalinhamento. Você acha que o dev sabe o que você quer. Depois vê o que foi construído — e percebe que não entendeu nada.

É a mesma coisa na era da IA. Há um gap de comunicação entre você e o agente. A correção é uma **grilling session** — fazer o agente fazer perguntas detalhadas sobre o que você está construindo.

**A correção**:

- [`/grill-me`](./skills/productivity/grill-me/SKILL.md) — para usos não relacionados a código
- [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) — igual ao [`/grill-me`](./skills/productivity/grill-me/SKILL.md), com extras (veja abaixo)

São as skills mais úteis do repositório. Ajudam a alinhar com o agente antes de começar e a pensar profundamente sobre a mudança. Use _sempre_ que for fazer uma alteração.

### #2: O agente é verboso demais

> With a ubiquitous language, conversations among developers and expressions of the code are all derived from the same domain model.
>
> Eric Evans, [Domain-Driven-Design](https://www.amazon.co.uk/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)

**O problema**: No início de um projeto, devs e as pessoas para quem constroem o software (os especialistas de domínio) costumam falar línguas diferentes.

A mesma tensão aparece com agentes. Eles entram num projeto e precisam decifrar o jargão no caminho. Resultado: 20 palavras onde 1 bastaria.

**A correção** é uma linguagem compartilhada — um documento que ajuda agentes a decodificar o jargão do projeto.

<details>
<summary>
Exemplo
</summary>

Veja um exemplo em [`CONTEXT.md`](./CONTEXT.md). Qual é mais fácil de ler?

- **ANTES**: "There's a problem when a lesson inside a section of a course is made 'real' (i.e. given a spot in the file system)"
- **DEPOIS**: "There's a problem with the materialization cascade"

Essa concisão paga dividendos sessão após sessão.

</details>

Isso está embutido em [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md). É uma grilling session que também ajuda a construir linguagem compartilhada com a IA e documentar decisões difíceis em ADRs.

Difícil explicar o quão poderoso isso é. Pode ser a técnica mais impactante deste repositório. Experimente.

> [!TIP]
> Uma linguagem compartilhada traz outros benefícios além de reduzir verbosidade:
>
> - **Variáveis, funções e arquivos são nomeados de forma consistente**, usando a linguagem compartilhada
> - Como resultado, o **codebase fica mais fácil de navegar** para o agente
> - O agente também **gasta menos tokens pensando**, porque tem acesso a uma linguagem mais concisa

### #3: O código não funciona

> "Always take small, deliberate steps. The rate of feedback is your speed limit. Never take on a task that's too big."
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**O problema**: Digamos que você e o agente estão alinhados sobre o que construir. E quando o agente _ainda_ produz lixo?

Hora de olhar os feedback loops. Sem feedback sobre como o código realmente roda, o agente voa às cegas.

**A correção**: Os feedback loops de sempre — tipos estáticos, acesso ao browser, testes automatizados.

Para testes automatizados, o loop red-green-refactor é crítico. O agente escreve um teste falhando primeiro, depois corrige. Isso dá um nível consistente de feedback que resulta em código bem melhor.

A skill **[`/tdd`](./skills/engineering/tdd/SKILL.md)** encaixa em qualquer projeto. Encoraja red-green-refactor e dá ao agente orientação sobre testes bons e ruins.

Para debugging, a skill **[`/diagnosing-bugs`](./skills/engineering/diagnosing-bugs/SKILL.md)** encapsula boas práticas num loop simples.

### #4: Construímos uma bola de lama

> "Invest in the design of the system _every day_."
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.co.uk/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

> "The best modules are deep. They allow a lot of functionality to be accessed through a simple interface."
>
> John Ousterhout, [A Philosophy Of Software Design](https://www.amazon.co.uk/Philosophy-Software-Design-2nd/dp/173210221X)

**O problema**: A maioria dos apps construídos com agentes é complexa e difícil de mudar. Agentes aceleram codificação — e também aceleram entropia de software. Codebases ficam complexas num ritmo sem precedentes.

**A correção** é uma abordagem radical ao desenvolvimento com IA: se importar com o design do código.

Isso está embutido em cada camada destas skills:

- [`/to-prd`](./skills/engineering/to-prd/SKILL.md) questiona quais módulos você está tocando antes de criar um PRD

E crucialmente, [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) ajuda a resgatar um codebase que virou bola de lama. Vale rodar no seu codebase a cada poucos dias.

### Resumo

Fundamentos de engenharia de software importam mais do que nunca. Estas skills condensam esses fundamentos em práticas repetíveis, para ajudar a entregar os melhores apps da sua carreira.

## Skills disponíveis

These split on one axis — who can invoke them. **User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you _or_ reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills I use daily for code work.

**User-invoked**

- **[ask-matt](./skills/engineering/ask-matt/SKILL.md)** — Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that also builds your project's domain model, sharpening terminology and updating `CONTEXT.md` and ADRs inline.
- **[triage](./skills/engineering/triage/SKILL.md)** — Move issues through a state machine of triage roles.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- **[setup-skills](./skills/engineering/setup-skills/SKILL.md)** — Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo before using the other engineering skills.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Break any plan, spec, or PRD into independently-grabbable issues using vertical slices.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Turn the current conversation into a PRD and publish it to the issue tracker. No interview — just synthesizes what you've already discussed.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design — either a runnable terminal app for state/business-logic questions, or several radically different UI variations toggleable from one route.

**Model-invoked**

- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)** — Actively build and sharpen a project's domain model — challenge terms against the glossary, stress-test with edge-case scenarios, and update `CONTEXT.md` and ADRs inline.
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)** — Shared discipline and vocabulary for designing deep modules: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/productivity/teach/SKILL.md)** — Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[writing-great-skills](./skills/productivity/writing-great-skills/SKILL.md)** — Reference for writing and editing skills well: the vocabulary and principles that make a skill predictable.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)** — Interview the user relentlessly about a plan or design until every branch of the decision tree is resolved. The reusable loop behind `grill-me` and `grill-with-docs`.

### Misc

- **[git-guardrails-claude-code](./skills/misc/git-guardrails-claude-code/SKILL.md)** — Set up Claude Code hooks to block dangerous git commands before they execute.
- **[migrate-to-shoehorn](./skills/misc/migrate-to-shoehorn/SKILL.md)** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.
- **[scaffold-exercises](./skills/misc/scaffold-exercises/SKILL.md)** — Create exercise directory structures with sections, problems, solutions, and explainers.
- **[setup-pre-commit](./skills/misc/setup-pre-commit/SKILL.md)** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.
- **[setup-statusline](./skills/misc/setup-statusline/SKILL.md)** — Install a Claude Code status line showing model, context usage, session cost, rate limits, and git branch.

## Dev local

```bash
./scripts/link-skills.sh    # symlink em ~/.claude/skills
./scripts/unlink-skills.sh  # remove symlinks
./scripts/list-skills.sh    # lista todos os SKILL.md
```
