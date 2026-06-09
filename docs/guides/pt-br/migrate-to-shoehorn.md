# `/migrate-to-shoehorn` — Migrar Asserções `as` para Shoehorn

## O que é

Uma skill que migra arquivos de teste com asserções `as` do TypeScript para `@total-typescript/shoehorn`, uma biblioteca que permite passar dados parciais em testes de forma type-safe.

## Para que serve

- Quando seus testes estão cheios de `as Type` ou `as unknown as Type`
- Quando você quer passar objetos parciais em testes sem fazer fake de todas as propriedades
- Para testes em TypeScript onde você precisa de dados intencionalmente errados (para testar erros)
- Como parte de uma limpeza de código de testes

**Importante**: Somente para código de testes. Nunca use shoehorn em código de produção.

## Como invocar

```
/migrate-to-shoehorn
```

## Por que usar

Problemas com `as` em testes:
- Você foi treinado a não usar `as`
- Precisa especificar o tipo alvo manualmente
- `as unknown as Type` é verboso para dados intencionalmente errados

### Comparação

**Antes (com `as`):**
```ts
// Objeto grande, só importa body.id
getUser({ body: { id: "123" } } as Request);

// Dado intencionalmente errado
getUser({ body: { id: 123 } } as unknown as Request);
```

**Depois (com shoehorn):**
```ts
import { fromPartial, fromAny } from "@total-typescript/shoehorn";

// Objeto parcial type-safe
getUser(fromPartial({ body: { id: "123" } }));

// Dado intencionalmente errado, mas com autocomplete
getUser(fromAny({ body: { id: 123 } }));
```

## Como funciona

### Funções disponíveis

| Função | Uso |
|--------|-----|
| `fromPartial()` | Dados parciais que ainda type-checam |
| `fromAny()` | Dados intencionalmente errados (mantém autocomplete) |
| `fromExact()` | Força objeto completo (troca com fromPartial depois) |

### Processo

**1. Coleta requisitos** — pergunta:
- Quais arquivos de teste têm asserções `as` causando problemas?
- Estão lidando com objetos grandes onde só algumas propriedades importam?
- Precisam passar dados intencionalmente errados para testes de erro?

**2. Instala e migra:**
```bash
npm i @total-typescript/shoehorn
```

- Encontra arquivos de teste com asserções `as`:
  ```bash
  grep -r " as [A-Z]" --include="*.test.ts" --include="*.spec.ts"
  ```
- Substitui `as Type` com `fromPartial()`
- Substitui `as unknown as Type` com `fromAny()`
- Adiciona imports de `@total-typescript/shoehorn`
- Roda type check para verificar

## Exemplo de uso

```
Meus testes têm muitos `as Request` e `as unknown as Response`. Quero migrar para shoehorn.

/migrate-to-shoehorn
```

O agente vai perguntar quais arquivos têm o problema, instalar a lib, e fazer a migração com verificação de tipos ao final.
