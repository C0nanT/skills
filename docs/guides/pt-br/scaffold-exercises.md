# `/scaffold-exercises` — Criar Estrutura de Exercícios

## O que é

Uma skill específica para criar estruturas de diretórios de exercícios de cursos que passam no linter `pnpm ai-hero-cli internal lint`.

## Para que serve

- Criar a estrutura de um novo exercício em um curso
- Adicionar uma nova seção com múltiplos exercícios
- Fazer scaffolding em lote a partir de um plano de conteúdo

**Nota**: Esta é uma skill específica para projetos que usam o `ai-hero-cli`. É improvável que seja útil fora desse contexto.

## Como invocar

```
/scaffold-exercises
```

Descreva o que você quer criar (seção, exercícios, variantes).

## Como funciona

### Estrutura de nomes

- **Seções**: `XX-section-name/` dentro de `exercises/` (ex: `01-retrieval-skill-building`)
- **Exercícios**: `XX.YY-exercise-name/` dentro de uma seção (ex: `01.03-retrieval-with-bm25`)
- Nomes em dash-case (minúsculas, hífens)

### Variantes por exercício

Cada exercício tem pelo menos uma das pastas:
- `problem/` — workspace do estudante com TODOs
- `solution/` — implementação de referência
- `explainer/` — material conceitual, sem TODOs

Padrão ao fazer stub: `explainer/` a menos que o plano especifique outra coisa.

### Arquivos obrigatórios

Cada subpasta precisa de um `readme.md` que:
- Não está vazio
- Não tem links quebrados

Stub mínimo:
```md
# Exercise Title

Description here
```

Se a subpasta tem código, precisa de `main.ts` (>1 linha).

### Processo

1. Parse do plano — extrai nomes de seções, exercícios, tipos de variantes
2. Cria diretórios com `mkdir -p`
3. Cria readmes stub com título
4. Roda `pnpm ai-hero-cli internal lint` para validar
5. Corrige erros e itera até o lint passar
6. Faz commit

### Regras do linter

O linter verifica:
- Exercício tem subpastas (`problem/`, `solution/`, `explainer/`)
- Pelo menos um de `problem/`, `explainer/`, ou `explainer.1/` existe
- `readme.md` existe e não está vazio na subpasta principal
- Sem arquivos `.gitkeep`
- Sem arquivos `speaker-notes.md`
- Sem links quebrados nos readmes
- `main.ts` obrigatório por subpasta (a menos que seja só readme)

### Mover ou renumerar exercícios

Use `git mv` (não `mv`) para preservar o histórico do git. Atualize o prefixo numérico para manter a ordem. Re-rode o lint após mover.

## Exemplo de uso

```
Quero criar a seção 05: Memory Skill Building, com 3 exercícios:
- 05.01 Introduction to Memory (explainer)
- 05.02 Short-term Memory (explainer + problem + solution)
- 05.03 Long-term Memory (explainer)

/scaffold-exercises
```

O agente vai criar os diretórios, criar os readmes stub, rodar o lint, e commitar.
