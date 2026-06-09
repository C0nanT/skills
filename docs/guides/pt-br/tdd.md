# `/tdd` — Desenvolvimento Orientado a Testes (TDD)

## O que é

Uma skill que implementa o ciclo red-green-refactor de TDD de forma disciplinada. Constrói features ou corrige bugs escrevendo um teste que falha primeiro, depois implementa o mínimo necessário para ele passar, e repete.

## Para que serve

- Quando quer construir uma feature nova com testes desde o início
- Quando quer corrigir um bug e garantir que ele não volte
- Quando quer testes de integração para um módulo específico
- Quando já tentou escrever código sem testes e está tendo problemas para testar depois

## Como invocar

```
/tdd
```

Descreva o que você quer construir ou corrigir.

## Como funciona

### Filosofia central

**Testes devem verificar comportamento através de interfaces públicas, não detalhes de implementação.** O código pode mudar completamente; os testes não deveriam precisar mudar.

Bom teste: exercita o código real por APIs públicas, descreve *o que* o sistema faz. Sobrevive a refatorações porque não se importa com estrutura interna.

Mau teste: mocka colaboradores internos, testa métodos privados, ou verifica através de meios externos. Sinal de alerta: o teste quebra quando você refatora, mas o comportamento não mudou.

### Anti-padrão: fatias horizontais

**NÃO** escreva todos os testes primeiro, depois toda a implementação. Isso produz testes ruins escritos para comportamento imaginado — não real.

```
ERRADO (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

CERTO (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  ...
```

### Processo

**1. Planejamento** — antes de escrever qualquer código:
- Confirma com o usuário quais mudanças de interface são necessárias
- Confirma quais comportamentos testar (prioriza)
- Identifica oportunidades de módulos profundos (interface pequena, implementação rica)
- Lista os comportamentos a testar (não os passos de implementação)
- Pede aprovação do plano

**2. Tracer bullet** — escreve UM teste que confirma UMA coisa:
```
RED:   Escreve teste para o primeiro comportamento → teste falha
GREEN: Escreve o mínimo de código para passar → teste passa
```

**3. Loop incremental** — para cada comportamento restante:
```
RED:   Escreve próximo teste → falha
GREEN: Código mínimo para passar → passa
```

Regras:
- Um teste por vez
- Só código suficiente para passar o teste atual
- Não antecipa testes futuros
- Testes focados em comportamento observável

**4. Refatorar** — só depois que todos os testes passam:
- Extrai duplicação
- Aprofunda módulos (move complexidade atrás de interfaces simples)
- Aplica SOLID onde natural
- Roda testes após cada passo de refatoração

**Nunca refatora enquanto RED.** Primeiro chega ao GREEN.

### Checklist por ciclo

```
[ ] Teste descreve comportamento, não implementação
[ ] Teste usa só interface pública
[ ] Teste sobreviveria a refatoração interna
[ ] Código é mínimo para este teste
[ ] Sem features especulativas adicionadas
```

## Exemplo de uso

```
Quero implementar uma função de busca de usuários por email. Pode ser exata ou parcial.

/tdd
```

O agente vai planejar: "Quais comportamentos importam? Busca exata encontra um usuário. Busca parcial retorna múltiplos. Email inexistente retorna vazio. Qual interface — `findUser(email: string): User | null` ou outra coisa?" — depois vai implementar um teste por vez.

## Dicas

- Você não consegue testar tudo — confirme com o agente quais comportamentos são mais críticos
- Testes de integração são preferíveis a testes unitários com mocks pesados — exercitam o comportamento real
- Use o glossário do domínio do projeto nos nomes dos testes para manter consistência
