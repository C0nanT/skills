# `/implement` — Implementar trabalho de um spec ou issues

## O que é

Uma skill user-invoked que implementa o trabalho descrito num spec ou conjunto de issues. É o passo de execução depois de `/to-tickets` ou de issues já prontas no issue tracker.

## Para que serve

- Implementar uma issue ou fatia vertical já especificada
- Executar um spec quebrado em tickets
- Trabalho AFK com contexto mínimo (passe o spec + a issue)

## Como invocar

```
/implement
```

Forneça o spec e/ou a(s) issue(s) a implementar — por link, número, ou colando o conteúdo.

Exemplo após `/to-tickets`:

```
/implement spec na issue #23, implementar só a issue #45
```

## Como funciona

1. Lê o spec e a issue indicada
2. Usa **`/tdd`** onde fizer sentido, nos seams já acordados
3. Roda typecheck regularmente, testes de arquivo único durante o trabalho, suite completa no final
4. Ao terminar, usa **[`/review`](./review.md)** para revisar o trabalho
5. Faz commit na branch atual

## Onde entra no fluxo

No fluxo principal (`/ask-skills`):

- Build **multi-sessão**: `/to-spec` → `/to-tickets` → **sessão nova por issue** → `/implement`
- Build **single-session**: `/grill-with-docs` (e opcionalmente `/prototype`) → `/implement` na mesma janela

Issues marcadas como `ready-for-agent` no issue tracker também chegam aqui.

## Dicas

- Uma issue por sessão mantém contexto limpo e focado.
- Se o seam de teste não estiver claro, volte ao planejamento com `/tdd` antes de codar em massa.
- `/implement` assume que a especificação já está pronta — não substitui `/grill-with-docs`.
