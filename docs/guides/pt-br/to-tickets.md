# `/to-tickets` — Converter Plano em Issues

## O que é

Uma skill que quebra um plano, spec, ou spec em issues independentes e grabáveis no issue tracker do projeto, usando fatias verticais (tracer bullets).

## Para que serve

- Quando você tem um plano ou spec e quer transformá-lo em tickets concretos
- Para quebrar trabalho grande em partes implementáveis independentemente
- Quando quer criar issues prontas para um agente AFK pegar e executar
- Para garantir que cada ticket seja uma fatia vertical completa, não uma camada horizontal

## Como invocar

```
/to-tickets
```

Ou passando uma issue existente como ponto de partida:

```
/to-tickets #42
/to-tickets https://github.com/org/repo/issues/42
```

**Pré-requisito**: rode `/setup-skills` antes de usar pela primeira vez.

## Como funciona

### O que são fatias verticais

Cada issue é uma **fatia tracer bullet** — um corte fino que atravessa *todas* as camadas de integração de ponta a ponta, não uma camada horizontal de uma única camada.

```
ERRADO (horizontal por camada):
  Issue 1: Criar tabela no banco
  Issue 2: Criar endpoint da API
  Issue 3: Criar componente de UI

CERTO (vertical por funcionalidade):
  Issue 1: Usuário pode ver lista vazia de pedidos (schema + endpoint + UI básica)
  Issue 2: Usuário pode criar um pedido simples (form + POST + persistência)
  Issue 3: Usuário pode cancelar um pedido (botão + endpoint + atualização de estado)
```

Cada fatia correta é demonstrável ou verificável sozinha.

### Processo

**1. Coleta contexto** — lê o que está na conversa. Se foi passado um número de issue, busca o corpo completo e comentários.

**2. Explora a codebase** — usa o glossário de domínio do projeto para que os títulos e descrições das issues usem vocabulário consistente.

**3. Rascunha fatias** — quebra o plano em issues. Cada issue pode ser:
- **HITL** (Human In The Loop): requer interação humana (decisão arquitetural, design review)
- **AFK** (Away From Keyboard): pode ser implementada e mergeada sem interação humana

Prefere AFK sempre que possível.

**4. Apresenta e refina** — mostra a lista numerada com:
- Título
- Tipo (HITL/AFK)
- Bloqueado por (dependências)
- User stories cobertas

Pergunta se a granularidade está certa, se as dependências estão corretas, se alguma deve ser dividida ou mesclada. Itera até você aprovar.

**5. Publica** — cria as issues em ordem de dependência (blockers primeiro) para poder referenciar IDs reais no campo "Bloqueado por". Usa o template:

```
## O que construir
[descrição do comportamento end-to-end]

## Critérios de aceite
- [ ] Critério 1
- [ ] Critério 2

## Bloqueado por
- #XYZ ou "Nenhum — pode começar imediatamente"
```

## Exemplo de uso

```
Aqui está o spec para o sistema de notificações: [cola o spec]

/to-tickets
```

O agente vai propor algo como: Issue 1 (AFK) - notificação ao comentar numa tarefa; Issue 2 (AFK) - badge de não-lidas no ícone; Issue 3 (HITL) - configurações de preferência de notificação (requer decisão de design).

## Dicas

- Issues publicadas recebem o label `ready-for-agent` automaticamente, a menos que você instrua diferente
- Snippets de código de protótipos podem ser incluídos nas issues quando codificam uma decisão de forma mais precisa que prosa
- A issue pai nunca é fechada ou modificada pela skill
