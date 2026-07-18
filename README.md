# conan-skills

Coleção de agent skills (comandos `/slash`) para Claude Code. Fork do [repositório do Matt Pocock](https://github.com/mattpocock/skills).

## Instalar

```bash
npx skills@latest add C0nanT/skills
```

### Hooks

Os hooks são gerenciados pelo projeto separado [claude-hooks](https://github.com/C0nanT/claude-hooks):

```bash
npx @c0nant/claude-hooks install
```

Instala estes hooks no `~/.claude/settings.json`:

| Hook | Evento | O que faz |
| ------ | -------- | ----------- |
| **caveman** | `SessionStart` | Modo caveman automático em toda sessão (requer a skill `caveman` instalada) |
| **git-guardrails** | `PreToolUse/Bash` | Bloqueia git destrutivo antes de executar (`push`, `reset --hard`, `clean -f`, etc.) |
| **protect-dotenv** | `PreToolUse` | Bloqueia leitura/edição de `.env` (permite `.env.example`, `.env.sample`, etc.) |
| **notify-attention** | `Notification` | Notificação desktop + som quando o agente precisa de input |
| **notify-done** | `Stop` | Notificação desktop + som quando o agente termina a resposta |

`caveman` no-op se a skill estiver ausente. Os demais são autossuficientes (scripts em `~/.claude/hooks-lib/`).

Instalar/remover um hook só:

```bash
npx @c0nant/claude-hooks install protect-dotenv
npx @c0nant/claude-hooks uninstall notify-done
npx @c0nant/claude-hooks list
```

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

- [`/to-spec`](./skills/engineering/to-spec/SKILL.md) quizzes you about which modules you're touching before creating a spec

E crucialmente, [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) ajuda a resgatar um codebase que virou bola de lama. Vale rodar no seu codebase a cada poucos dias.

### Resumo

Fundamentos de engenharia de software importam mais do que nunca. Estas skills condensam esses fundamentos em práticas repetíveis, para ajudar a entregar os melhores apps da sua carreira.

## Skills disponíveis

These split on one axis — who can invoke them. **User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you _or_ reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills I use daily for code work.

**User-invoked**

- **[ask-skills](./skills/engineering/ask-skills/SKILL.md)** — Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[delegate-tickets](./skills/engineering/delegate-tickets/SKILL.md)** — Orchestrate sequential ticket implementation through fresh subagents, one ticket at a time, each required to use the `implement` skill.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that also builds your project's domain model, sharpening terminology and updating `CONTEXT.md` and ADRs inline.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.  
- **[setup-skills](./skills/engineering/setup-skills/SKILL.md)** — Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo before using the other engineering skills.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)** — Turn the current conversation into a spec and publish it to the issue tracker. No interview — just synthesizes what you've already discussed.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)** — Break any plan, spec, or conversation into a set of tracer-bullet tickets, each declaring its blocking edges — written as text in a local file, or as native blocking links on a real tracker.
- **[implement](./skills/engineering/implement/SKILL.md)** — Build the work described by a spec or set of tickets, driving `/tdd` at pre-agreed seams and closing out with `/review-axes` before committing.
- **[wayfinder](./skills/engineering/wayfinder/SKILL.md)** — Plan a huge chunk of work, more than one agent session can hold, as a shared map of investigation tickets on the issue tracker — resolve them one at a time until the way to the destination is clear.

**Model-invoked**

- **[prototype](./skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to answer a design question — a runnable terminal app for state/logic questions, or several radically different UI variations toggleable from one route.
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[research](./skills/engineering/research/SKILL.md)** — Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[resolving-merge-conflicts](./skills/engineering/resolving-merge-conflicts/SKILL.md)** — Use when you need to resolve an in-progress git merge/rebase conflict.
- **[review-axes](./skills/engineering/review-axes/SKILL.md)** — Two-axis review of the diff since a fixed point: **Standards** (does it follow the repo's coding standards, plus a Fowler smell baseline?) and **Spec** (does it faithfully implement the originating issue/spec?), run as parallel sub-agents so neither pollutes the other.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[writing-great-skills](./skills/productivity/writing-great-skills/SKILL.md)** — Reference for writing and editing skills well: the vocabulary and principles that make a skill predictable.

**Model-invoked**

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode: drops articles, filler, and pleasantries while keeping full technical accuracy (~75% fewer tokens). Optionally auto-activated each session via the claude-hooks SessionStart hook.
- **[grilling](./skills/productivity/grilling/SKILL.md)** — Interview the user relentlessly about a plan or design until every branch of the decision tree is resolved. The reusable loop behind `grill-me` and `grill-with-docs`.

### Misc

- **[setup-pre-commit](./skills/misc/setup-pre-commit/SKILL.md)** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.
- **[setup-statusline](./skills/misc/setup-statusline/SKILL.md)** — Install a Claude Code status line showing model, context usage (% + tokens), rate limits, and git branch.
- **[reset-agent-env](./skills/misc/reset-agent-env/SKILL.md)** — Wipe global agent skills, hooks, rules, and MCP configs across Claude Code, Cursor, Windsurf, and Antigravity (dry-run by default; backs up before deleting) to simulate a clean machine.

## Dev local

```bash
./scripts/list-skills.sh    # lista todos os SKILL.md
./scripts/sync-upstream.sh  # merge upstream (mattpocock/skills) e remove as skills excluídas deste fork
```
