```yaml
name: tdd
description: Desenvolvimento orientado a testes. Use quando o usuário quiser construir funcionalidades ou corrigir bugs escrevendo o teste primeiro, mencionar "red-green-refactor", ou quiser testes de integração.
```

# Desenvolvimento orientado a testes (TDD)

TDD é o ciclo vermelho → verde. Esta skill é a referência que faz esse ciclo produzir testes que valem a pena manter: o que é um bom teste, onde os testes ficam, os anti-padrões e as regras do ciclo. Cada seção se aplica a todo ciclo: consulte-as antes e durante o ciclo, não depois.

Ao explorar a base de código, leia o `GLOSSARY.md` (se existir), para que os nomes dos testes e o vocabulário de interface combinem com a linguagem de domínio do projeto, e respeite os ADRs da área que você está alterando.

## O que é um bom teste

Os testes verificam o comportamento por meio de interfaces públicas, não detalhes de implementação. O código pode mudar por completo; os testes não deveriam. Um bom teste lê-se como uma especificação: "usuário consegue finalizar a compra com carrinho válido" diz exatamente qual capacidade existe, e sobrevive a refatorações porque não se importa com a estrutura interna.

## Seams: onde os testes ficam

Um **seam** é a fronteira pública em que você testa: a interface onde você observa o comportamento sem entrar por dentro. Os testes ficam nos seams, nunca contra os internos.

**Teste apenas em seams acordados previamente.** Nenhum teste é escrito em um seam não confirmado. Você não consegue testar tudo, e acordar os seams antecipadamente é o que faz o esforço de teste cair nos caminhos críticos e na lógica complexa, em vez de cobrir cada caso de borda.

Os seams podem já estar acordados. Use a primeira fonte que existir:

1. A linha `Seams:` do ticket (ou a seção `Seams` de um ticket remoto).
2. As Testing Decisions da especificação.
3. Nenhuma.

Seams vindos de uma fonte contam como confirmados: escreva testes neles sem perguntar. Pergunte ao usuário apenas sobre um seam que não está na lista, e acrescente-o à lista quando for acordado.

Sem nenhuma fonte (uso avulso, sem ticket nem especificação), anote os seams que serão testados e confirme-os com o usuário antes de escrever qualquer teste. Pergunte: "Qual é a interface pública, e quais seams devemos testar?" Dê a cada seam proposto uma nota de uma linha sobre o que ele pega e o que deixa passar.

Quando o formato dessa interface é em si uma dúvida (quão profundo é o módulo, onde o seam deve ficar, o que a interface deve expor), resolva isso primeiro e só depois acorde os seams.

## Anti-padrões

- **Acoplado à implementação**: usa mocks de colaboradores internos, testa métodos privados ou verifica por um canal lateral (consultar o banco de dados em vez de usar a interface). O sinal: o teste quebra quando você refatora, mas o comportamento não mudou.
- **Tautológico**: a asserção recalcula o valor esperado do mesmo jeito que o código faz (`expect(add(a, b)).toBe(a + b)`, um snapshot derivado à mão do mesmo modo, uma constante comparada consigo mesma), então passa por construção e nunca pode discordar do código. Valores esperados precisam vir de uma fonte independente da verdade: um literal conhecido como correto, um exemplo resolvido, a especificação.
- **Fatiamento horizontal**: escrever todos os testes primeiro e depois toda a implementação. Testes em massa verificam um comportamento _imaginado_: você testa a _forma_ das coisas em vez do comportamento voltado ao usuário, os testes ficam insensíveis a mudanças reais e você compromete a estrutura dos testes antes de entender a implementação. Trabalhe em **fatias verticais**: um teste → uma implementação → repita, cada teste sendo um **tracer bullet** que responde ao que o ciclo anterior ensinou.

## Regras do ciclo

- **Vermelho antes de verde.** Escreva primeiro o teste que falha, depois apenas o código suficiente para fazê-lo passar. Não antecipe testes futuros nem adicione funcionalidades especulativas.
- **Uma fatia por vez.** Um seam, um teste, uma implementação mínima por ciclo.
- **Refatorar não faz parte do ciclo.** Ele pertence à etapa Refactor da skill `implement`, e não ao ciclo de implementação vermelho → verde.
