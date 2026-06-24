# `/resolving-merge-conflicts` — Resolver conflitos de merge/rebase

## O que é

Uma skill (model-invoked) para resolver conflitos de git em merge ou rebase **em andamento**, preservando a intenção de ambos os lados quando possível.

## Para que serve

- `git merge` ou `git rebase` parou com conflitos
- Você quer que o agente entenda *por que* cada mudança existia antes de escolher hunks
- Precisa terminar o merge/rebase e passar nos checks do projeto

## Como invocar

Model-invoked quando você menciona conflito de merge/rebase. Também:

```
/resolving-merge-conflicts
```

## Como funciona

1. **Estado atual** — inspeciona merge/rebase, histórico git e arquivos em conflito.

2. **Fontes primárias** — para cada conflito, entende a intenção original: mensagens de commit, PRs, issues.

3. **Resolve cada hunk** — preserva ambas as intenções quando compatível. Se incompatível, escolhe o lado alinhado ao objetivo do merge e documenta o trade-off. **Não inventa comportamento novo.** Sempre resolve; nunca `--abort`.

4. **Checks automatizados** — descobre e roda (typecheck, testes, format). Corrige o que o merge quebrou.

5. **Finaliza** — stage tudo, commit. Em rebase, continua até rebasar todos os commits.

## Exemplo de uso

```
Estou no meio de um rebase e tenho conflitos em src/auth.ts e package.json.

/resolving-merge-conflicts
```

O agente mapeia as mudanças de cada lado, propõe resoluções, roda os checks e completa o rebase.

## Dicas

- Quanto mais contexto sobre o objetivo do merge (feature branch, hotfix), melhor a resolução.
- Se um lado for claramente obsoleto, diga — mas o agente ainda deve justificar a escolha.
