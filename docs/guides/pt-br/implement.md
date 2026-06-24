# `/implement` — Implementar trabalho de um PRD ou issues

## O que é

Uma skill user-invoked que implementa o trabalho descrito num PRD ou conjunto de issues. É o passo de execução depois de `/to-issues` ou de issues já prontas no issue tracker.

## Para que serve

- Implementar uma issue ou fatia vertical já especificada
- Executar um PRD quebrado em tickets
- Trabalho AFK com contexto mínimo (passe o PRD + a issue)

## Como invocar

```
/implement
```

Forneça o PRD e/ou a(s) issue(s) a implementar — por link, número, ou colando o conteúdo.

Exemplo após `/to-issues`:

```
/implement PRD na issue #23, implementar só a issue #45
```

## Como funciona

1. Lê o PRD e a issue indicada
2. Usa **`/tdd`** onde fizer sentido, nos seams já acordados
3. Roda typecheck regularmente, testes de arquivo único durante o trabalho, suite completa no final
4. Ao terminar, usa **`/review`** para revisar o trabalho
5. Faz commit na branch atual

## Onde entra no fluxo

No fluxo principal (`/ask-matt`):

- Build **multi-sessão**: `/to-prd` → `/to-issues` → **sessão nova por issue** → `/implement`
- Build **single-session**: `/grill-with-docs` (e opcionalmente `/prototype`) → `/implement` na mesma janela

Issues marcadas como `ready-for-agent` no issue tracker também chegam aqui.

## Dicas

- Uma issue por sessão mantém contexto limpo e focado.
- Se o seam de teste não estiver claro, volte ao planejamento com `/tdd` antes de codar em massa.
- `/implement` assume que a especificação já está pronta — não substitui `/grill-with-docs`.
