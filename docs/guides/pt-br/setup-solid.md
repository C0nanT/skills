# Setup SOLID

> Tradução em português da skill [`setup-solid`](../../../skills/engineering/setup-solid/SKILL.md). O conteúdo é o mesmo do `SKILL.md`; a skill que o agente executa é a versão em inglês.

Instala uma instrução duradoura no repositório: **aplique SOLID no nível de arquitetura, seguindo a boy scout rule.**

A **boy scout rule** é o ponto central deste setup. SOLID incide sobre o código que está sendo escrito agora e sobre o código pelo qual o fluxo atual já passa — nunca sobre o repositório inteiro. O codebase converge uma mudança por vez.

A seção é **agnóstica de linguagem**: fala em módulos, seams e direção de dependência, não no container de DI de um framework ou na palavra-chave `interface` de uma linguagem. O que a torna útil é a exploração da etapa 1 — a seção nomeia as camadas e caminhos reais *deste* repositório.

## Processo

### 1. Explorar

Leia o repositório antes de rascunhar. Não presuma:

- Linguagens e como o código é agrupado — pacotes, pastas, serviços. Quais pastas guardam **policy** (domínio / regras de negócio) e quais guardam **details** (banco, HTTP, SDKs, filesystem)?
- `CLAUDE.md` e `AGENTS.md` na raiz — algum deles existe? Já há uma seção `## SOLID`, ou uma seção de arquitetura / padrões de código que se sobreponha a ela?
- `CONTEXT.md` — o vocabulário de domínio que a seção deve usar para os conceitos deste repo.
- ADRs (`.agents/adr/`, `docs/adr/`) — decisões de arquitetura que a seção não pode contradizer.
- Como as dependências já são injetadas hoje (argumentos de construtor, parâmetros de função, um container, imports de módulo) e como os testes já as substituem — a seção deve descrever a convenção que existe, não importar uma nova.
- Se a documentação está escrita em inglês ou em outro idioma.

Concluído quando você conseguir nomear, nos caminhos reais deste repo, onde mora a policy, onde moram os details, e como os dois estão ligados hoje.

### 2. Rascunhar e confirmar

Mostre ao usuário a seção completa que você pretende escrever, com os marcadores preenchidos a partir da etapa 1. Pergunte apenas o que realmente bifurca:

- Em qual arquivo escrever, **somente** quando nem `CLAUDE.md` nem `AGENTS.md` existirem.
- Qualquer coisa que a exploração tenha deixado ambígua — por exemplo, duas pastas plausíveis para a policy.

Deixe o usuário editar o rascunho antes de você escrever.

### 3. Escrever

Escolha o arquivo: edite o `CLAUDE.md` se ele existir; senão o `AGENTS.md`; senão o que o usuário escolheu. Nunca crie um deles quando o outro já está lá.

Se já existir uma seção `## SOLID`, atualize-a no lugar. Deixe as seções ao redor intactas.

Escreva a seção no idioma em que o resto do arquivo está escrito.

A seção:

```markdown
## SOLID

Aplique SOLID no nível de **arquitetura** — fronteiras de módulo, direção das dependências e as interfaces entre eles. É uma forma de moldar seams, não um ritual de nomenclatura. "Módulo" significa aquilo em que este codebase agrupa comportamento: uma classe, um pacote, um arquivo de funções, um serviço.

### Escopo — boy scout rule

SOLID se aplica a:

- código escrito novo na mudança atual, e
- o código existente pelo qual o fluxo atual já passa, quando uma edição pequena e local remove um atrito que essa mudança está enfrentando.

O resto do codebase permanece como está. Mantenha o blast radius de uma mudança sobre o fluxo que está sendo construído ou corrigido — uma refatoração SOLID no repositório inteiro é um trabalho à parte, e só acontece quando pedida explicitamente. O codebase converge uma mudança por vez.

Quando aplicar um princípio exigiria remodelar módulos fora do fluxo atual, deixe-os em paz e diga isso no resumo da mudança.

### Os princípios, como regras de arquitetura

- **SRP** — um módulo tem uma razão para mudar. Quando um fluxo obriga a editar um módulo que outros fluxos também governam por razões não relacionadas, esse módulo está segurando duas responsabilidades.
- **OCP** — comportamento novo chega como uma nova implementação atrás de uma interface existente, em vez de mais um branch num condicional que cresce sobre tipos de coisa.
- **LSP** — toda implementação de uma interface é substituível através dessa interface: mesmo contrato, mesmo comportamento de erro, sem "esta aqui também precisa que X seja chamado antes".
- **ISP** — um consumidor depende da interface estreita que de fato usa. Interfaces são moldadas pela necessidade de quem chama, não por tudo o que a implementação sabe fazer.
- **DIP** — a policy [LOCAL DA POLICY] não depende dos details [LOCAL DOS DETAILS]. A interface pertence ao lado da policy; o detail a implementa e é passado por injeção [CONVENÇÃO DE INJEÇÃO].

### Aplicando

- Quando um fluxo novo cruza uma fronteira de IO, defina a interface a partir do lado da policy e injete a implementação.
- Uma implementação já basta — o seam se paga no momento em que um teste a substitui. Não adicione camadas de abstração com um único chamador e nenhuma substituição.
- Use o vocabulário de domínio deste repo (`CONTEXT.md`) ao nomear módulos e interfaces.
```

Preencha `[LOCAL DA POLICY]`, `[LOCAL DOS DETAILS]` e `[CONVENÇÃO DE INJEÇÃO]` com os caminhos e a convenção reais deste repo, vindos da etapa 1. Remova a linha do `CONTEXT.md` quando o repo não tiver esse arquivo, e remova qualquer bullet que contradiga um ADR registrado.

### 4. Concluído

Diga ao usuário qual arquivo você editou, e que SOLID agora se aplica a código novo e ao código que cada mudança já toca — nenhuma passada de refatoração separada está por vir. Re-rodar esta skill só é necessário para remodelar a própria seção; editá-la diretamente está ok.
