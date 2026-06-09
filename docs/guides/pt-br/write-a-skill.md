# `/write-a-skill` — Criar uma Nova Skill

## O que é

Uma skill que te ajuda a criar novas skills para o Claude Code com estrutura adequada, divulgação progressiva de conteúdo, e recursos agrupados.

## Para que serve

- Quando você quer criar uma nova skill personalizada
- Quando tem um processo repetitivo que quer transformar em skill
- Para garantir que a nova skill tenha a estrutura correta (description, SKILL.md, arquivos de referência)

## Como invocar

```
/write-a-skill
```

## Como funciona

### Processo

**1. Coleta requisitos** — pergunta:
- Qual tarefa/domínio a skill cobre?
- Quais casos de uso específicos deve tratar?
- Precisa de scripts executáveis ou só instruções?
- Há materiais de referência para incluir?

**2. Rascunha a skill** — cria:
- `SKILL.md` com instruções concisas
- Arquivos de referência adicionais se o conteúdo exceder 500 linhas
- Scripts utilitários se operações determinísticas forem necessárias

**3. Revisa com o usuário** — apresenta o rascunho e pergunta:
- Cobre os casos de uso?
- Algo faltando ou pouco claro?
- Alguma seção precisa de mais/menos detalhe?

### Estrutura de uma skill

```
skill-name/
├── SKILL.md           ← instruções principais (obrigatório)
├── REFERENCE.md       ← docs detalhados (se necessário)
├── EXAMPLES.md        ← exemplos de uso (se necessário)
└── scripts/           ← scripts utilitários (se necessário)
    └── helper.js
```

### A parte mais importante: a description

A `description` no frontmatter do `SKILL.md` é **a única coisa que o agente vê** quando decide qual skill carregar. Ela aparece no system prompt ao lado de todas as outras skills instaladas.

**Boas descriptions:**
- Máximo 1024 caracteres
- Escritas na terceira pessoa
- Primeira frase: o que a skill faz
- Segunda frase: "Use when [gatilhos específicos]"

```yaml
description: Diagnóstico disciplinado de bugs e regressões de performance. 
Use when user says "diagnose this" / "debug this", reports a bug, or describes 
a performance regression.
```

**Description ruim:**
```yaml
description: Helps with debugging.
```

### Quando dividir em múltiplos arquivos

Divida quando:
- `SKILL.md` excede ~100 linhas
- Conteúdo tem domínios distintos
- Features avançadas são raramente necessárias

### Quando adicionar scripts

Adicione scripts quando:
- Operação é determinística (validação, formatação)
- Mesmo código seria gerado repetidamente
- Erros precisam de tratamento explícito

Scripts economizam tokens e melhoram confiabilidade vs. código gerado na hora.

### Checklist de revisão

```
[ ] Description inclui gatilhos ("Use when...")
[ ] SKILL.md menor que 100 linhas
[ ] Sem informações com prazo de validade
[ ] Terminologia consistente
[ ] Exemplos concretos incluídos
[ ] Referências com no máximo um nível de profundidade
```

## Onde colocar a nova skill

Depois de criar, coloque no bucket correto:
- `skills/engineering/` — trabalho diário de código
- `skills/productivity/` — ferramentas de workflow não específicas de código
- `skills/misc/` — mantidas mas raramente usadas
- `skills/personal/` — ligadas à sua configuração específica, não promovidas
- `skills/in-progress/` — rascunhos ainda não prontos

Skills em `engineering/`, `productivity/`, e `misc/` precisam de entrada no `README.md` raiz e no `.claude-plugin/plugin.json`. Skills em `personal/` e `in-progress/` não aparecem em nenhum desses.
