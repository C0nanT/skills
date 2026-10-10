# Formato do relatório HTML

A revisão arquitetural é renderizada como um único arquivo HTML autocontido, no diretório temporário do sistema operacional. Tailwind e Mermaid vêm de CDNs. O Mermaid lida bem com diagramas em formato de grafo; divs feitas à mão e SVG inline cuidam dos visuais mais editoriais (diagramas de massa, cortes transversais). Combine os dois: não dependa do Mermaid para tudo, senão tudo vai parecer genérico.

## Esqueleto

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review for {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed seam lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Cabeçalho

Nome do repositório, data e uma legenda compacta: caixa sólida = módulo, linha tracejada = seam, seta vermelha = vazamento, caixa escura e espessa = módulo profundo. Sem parágrafo de introdução. Vá direto aos candidatos.

## Cartão de candidato

Os diagramas carregam o peso. A prosa é esparsa, simples e usa os termos do glossário de arquitetura sem cerimônia.

Cada candidato é um `<article>`:

- **Título**: curto, nomeia o aprofundamento (por exemplo, "Collapse the Order intake pipeline").
- **Linha de selos**: força da recomendação (`Strong` = esmeralda, `Worth exploring` = âmbar, `Speculative` = ardósia), mais uma tag da categoria de dependência (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Arquivos**: lista monoespaçada, `font-mono text-sm`.
- **Diagrama Antes / Depois**: a peça central. Duas colunas, lado a lado. Veja os padrões abaixo.
- **Problema**: uma frase. O que dói.
- **Solução**: uma frase. O que muda.
- **Ganhos**: bullets, até 6 palavras cada. Por exemplo: "Tests hit one interface", "Pricing logic stops leaking", "Delete 4 shallow wrappers".
- **Callout de ADR** (se aplicável): uma linha, em uma caixa com tom âmbar.

Nada de parágrafos de explicação. Se o diagrama precisar de um parágrafo para ser entendido, refaça o diagrama.

## Padrões de diagrama

Escolha o padrão que combina com o candidato. Misture-os. Não deixe todos os diagramas com a mesma cara: a variedade faz parte do objetivo.

### Grafo Mermaid (o cavalo de batalha para dependências e fluxo de chamadas)

Use um `flowchart` ou `graph` do Mermaid quando o ponto for "X chama Y, que chama Z, e veja a bagunça". Envolva-o em um cartão estilizado com Tailwind, para que não pareça colado de qualquer jeito. Estilize com classDef para pintar de vermelho as arestas de vazamento e de escuro o módulo profundo. Diagramas de sequência funcionam bem para "antes: 6 idas e voltas; depois: 1".

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### Caixas e setas feitas à mão (quando o layout do Mermaid briga com você)

Módulos como `<div>`s com bordas e rótulos. Setas como elementos `<line>` ou `<path>` de SVG inline, posicionados de forma absoluta sobre um contêiner relativo. Use isto quando quiser que o diagrama "depois" pareça um único módulo profundo, de borda grossa, com os internos esmaecidos, já que o Mermaid não renderiza isso com o peso certo.

### Corte transversal (bom para superficialidade em camadas)

Empilhe faixas horizontais (`h-12 border-l-4`) para mostrar as camadas que uma chamada atravessa. Antes: 6 camadas finas que não fazem nada. Depois: 1 faixa grossa, rotulada com a responsabilidade consolidada.

### Diagrama de massa (bom para "interface tão larga quanto a implementação")

Dois retângulos por módulo: um para a área da superfície da interface, outro para a implementação. Antes: o retângulo da interface é quase tão alto quanto o da implementação (raso). Depois: o retângulo da interface é baixo e o da implementação é alto (profundo).

### Colapso do grafo de chamadas

Antes: uma árvore de chamadas de função renderizada como caixas aninhadas. Depois: a mesma árvore colapsada em uma caixa só, com as chamadas agora internas mostradas esmaecidas dentro dela.

## Orientações de estilo

- Editorial, não painel corporativo. Espaço em branco generoso. Serifa opcional nos títulos (`font-serif` combina bem com stone/slate).
- Cor com moderação: um destaque (esmeralda ou índigo), mais vermelho para vazamento e âmbar para avisos.
- Mantenha os diagramas com cerca de 320px de altura, para que antes e depois fiquem confortáveis lado a lado sem rolagem.
- Use `text-xs uppercase tracking-wider` nos rótulos de módulo dentro dos diagramas, para que pareçam esquemáticos, não de interface.
- Os únicos scripts são o do CDN do Tailwind e o import ESM do Mermaid. Fora isso, o relatório é estático: sem código de aplicação, sem interatividade além da renderização do próprio Mermaid.

## Seção Top recommendation

Um cartão maior. Nome do candidato, uma frase sobre o porquê, link âncora para o cartão dele. Só isso.

## Tom

Português claro, conciso, mas os substantivos e verbos arquiteturais vêm direto do glossário de arquitetura. Concisão não é desculpa para fugir do vocabulário.

**Use exatamente:** module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

**Nunca substitua por:** component, service, unit (no lugar de module) · API, signature (no lugar de interface) · boundary (no lugar de seam) · layer, wrapper (no lugar de module, quando você quer dizer module).

**Frases que combinam com o estilo** (exemplos de texto para o relatório, mantidos em inglês como no original):

- "Order intake module is shallow: interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**Os bullets de ganhos** nomeiam o ganho com termos do glossário: _"locality: bugs concentrate in one module"_, _"leverage: one interface, N call sites"_, _"interface shrinks; implementation absorbs the wrappers"_. Não escreva _"easier to maintain"_ nem _"cleaner code"_, porque esses termos não estão no glossário e não merecem lugar.

Sem hedging, sem enrolação, sem "vale notar que…". Se uma frase pode ser um bullet, transforme-a em bullet. Se um bullet pode ser cortado, corte-o. Se um termo não está no glossário de arquitetura, procure um que esteja antes de inventar um novo.
