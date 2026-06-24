# `/grill-with-docs` — Grilling com Documentação de Domínio

## O que é

A versão engenharia-focada de `/grill-me`. Inicia **`/grilling`** e, em paralelo, lê e atualiza `CONTEXT.md` e ADRs conforme as decisões são tomadas.

## Para que serve

- Antes de implementar uma feature em um projeto que já tem documentação de domínio
- Para construir ou expandir o glossário de termos do projeto (`CONTEXT.md`)
- Para verificar se o plano bate com as decisões arquiteturais já registradas (ADRs)
- Para registrar novas decisões arquiteturais que surgem durante a conversa
- Para garantir que novos conceitos sejam nomeados consistentemente com a linguagem do projeto

## Como invocar

```
/grill-with-docs
```

Descreva o que você quer fazer. A skill vai explorar a codebase e a documentação existente antes de começar a entrevistar.

## Como funciona

### Durante a sessão, o agente:

**Desafia contra o glossário** — se você usa um termo que conflita com o `CONTEXT.md`, ele chama atenção na hora: *"Seu glossário define 'cancelamento' como X, mas você parece querer dizer Y — qual é?"*

**Afina linguagem vaga** — quando você usa termos ambíguos ou sobrecarregados, propõe um termo canônico preciso: *"Você está dizendo 'conta' — você quer dizer Customer ou User? São coisas diferentes."*

**Testa com cenários concretos** — inventa cenários para forçar você a ser preciso sobre as bordas entre conceitos.

**Cruza com o código** — quando você afirma como algo funciona, verifica se o código concorda. Se encontrar contradição, expõe: *"Seu código cancela Orders inteiras, mas você acabou de dizer que cancelamento parcial é possível — qual é o correto?"*

**Atualiza `CONTEXT.md` inline** — quando um termo é resolvido, atualiza o glossário imediatamente, sem acumular.

**Oferece ADRs com parcimônia** — só propõe criar um ADR quando a decisão é: difícil de reverter, surpreendente sem contexto, e resultado de um trade-off real entre alternativas reais.

## Estrutura de arquivos esperada

O agente procura pela documentação aqui:

```
/
├── CONTEXT.md          ← glossário do domínio
└── docs/
    └── adr/
        ├── 0001-...md  ← decisões arquiteturais
        └── 0002-...md
```

Para monorepos com múltiplos contextos, cria um `CONTEXT-MAP.md` na raiz apontando para os contextos de cada módulo.

Os arquivos são criados de forma lazy — só quando há algo para escrever.

## Diferença de `/grill-me`

`/grill-me` faz perguntas sem contexto do projeto.

`/grill-with-docs` lê o glossário existente, ADRs, e o código antes de perguntar. Atualiza a documentação conforme a conversa avança. É a versão para projetos com histórico.

## Exemplo de uso

```
Quero adicionar um sistema de permissões baseado em roles ao projeto. Usuários admin podem tudo, managers podem criar/editar, viewers só leem.

/grill-with-docs
```

O agente vai primeiro ler `CONTEXT.md` para ver se "Role", "Permission", "User" já estão definidos, ler os ADRs para ver se já houve decisões sobre autenticação/autorização, e então começar a entrevistar — atualizando o glossário a cada termo novo que for resolvido.

## Por que usar

Cria uma linguagem compartilhada entre você e o agente que paga dividendos em cada sessão futura: variáveis nomeadas consistentemente, agente gastando menos tokens em ambiguidade, codebase mais navegável.
