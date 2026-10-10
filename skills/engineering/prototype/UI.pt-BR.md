# Protótipo de UI

Gere **várias variações de UI radicalmente diferentes** em uma única rota, alternáveis por uma barra flutuante inferior. O usuário alterna entre as variantes no navegador, escolhe uma (ou aproveita partes de cada uma) e depois descarta as outras.

Se a pergunta for sobre lógica/estado e não sobre aparência, este é o branch errado. Use [LOGIC.pt-BR.md](LOGIC.pt-BR.md).

## Quando este é o formato certo

- "Como esta página deveria parecer?"
- "Quero ver algumas opções para este dashboard antes de me comprometer."
- "Experimente um layout diferente para a tela de configurações."
- Sempre que o usuário fosse gastar um dia escolhendo entre três maquetes vagas na própria cabeça.

## Dois subformatos: prefira fortemente o subformato A

Um protótipo de UI é muito mais fácil de julgar quando está **encostado no resto do app**: cabeçalho real, barra lateral real, dados reais, densidade real. Uma rota descartável sozinha é um vácuo: qualquer variante parece boa isolada. Use por padrão o subformato A sempre que houver uma página plausível já existente para hospedar as variantes. Recorra ao subformato B só se o protótipo realmente não tiver um lar próximo.

### Subformato A: ajuste em uma página existente (preferido)

A rota já existe. As variantes são renderizadas **na mesma rota**, controladas por um parâmetro de busca na URL, `?variant=`. A busca de dados, os parâmetros e a autenticação existentes continuam os mesmos. Só a renderização muda. Este é o padrão; escolha-o a menos que haja um motivo específico para não fazê-lo.

Se o protótipo for para algo que ainda não tem página, mas que _naturalmente moraria dentro de uma_ (uma nova seção do dashboard, um novo cartão na tela de configurações, um novo passo em um fluxo existente), continua sendo subformato A. Monte as variantes dentro da página hospedeira.

### Subformato B: uma nova página (último recurso)

Use isto somente quando aquilo que está sendo prototipado realmente não tiver uma página existente onde morar (por exemplo, uma superfície de topo totalmente nova, ou um fluxo que não pode ser embutido em lugar nenhum de forma sensata).

Crie uma **rota descartável** seguindo a convenção de roteamento que o projeto já usa. Não invente uma nova estrutura de topo. Dê um nome que deixe óbvio que é um protótipo (por exemplo, incluir a palavra `prototype` no caminho ou no nome do arquivo). Mesmo padrão `?variant=`.

Antes de se comprometer com o subformato B, faça uma checagem de sanidade: realmente não há nenhuma página existente onde isto possa ser embutido? Uma rota vazia esconde problemas de design que uma rota populada revelaria.

Nos dois subformatos, a barra flutuante inferior é idêntica.

## Processo

### 1. Enuncie a pergunta e escolha N

Por padrão, use **3 variantes**. Mais de 5 deixa de ser radicalmente diferente e vira ruído, então limite nesse ponto.

Escreva o plano em uma linha, no local do protótipo ou em um comentário no topo do arquivo:

> "Três variantes da página de configurações, alternáveis via `?variant=`, na rota existente `/settings`."

Isso funciona quer o usuário esteja aqui para contestar, quer não.

### 2. Gere variantes radicalmente diferentes

Rascunhe cada variante. Mantenha cada uma dentro destes limites:

- O propósito da página e os dados a que ela tem acesso.
- A biblioteca de componentes / sistema de estilos do projeto (TailwindCSS, shadcn, MUI, CSS puro, o que houver).
- Um nome de componente exportado claro, por exemplo `VariantA`, `VariantB`, `VariantC`.

As variantes precisam ser **estruturalmente diferentes**: layout diferente, hierarquia de informação diferente, affordance principal diferente, e não apenas cores diferentes. Três grades de cartões levemente ajustadas não é um protótipo de UI, é papel de parede. Se dois rascunhos saírem parecidos demais, refaça um deles com uma orientação explícita de "não use grade de cartões".

### 3. Conecte tudo

Crie um único componente seletor na rota:

```tsx
// pseudo-code, adapt to the project's framework
const variant = searchParams.get('variant') ?? 'A';
return (
  <>
    {variant === 'A' && <VariantA {...data} />}
    {variant === 'B' && <VariantB {...data} />}
    {variant === 'C' && <VariantC {...data} />}
    <PrototypeSwitcher variants={['A','B','C']} current={variant} />
  </>
);
```

Para o subformato A (página existente): mantenha toda a busca de dados existente acima do seletor; apenas a subárvore renderizada muda por variante.

Para o subformato B (nova página): a rota descartável em `/prototype/<name>` monta o mesmo seletor.

### 4. Construa o seletor flutuante

Uma pequena barra de posição fixa, no centro inferior da tela, com três partes:

- **Seta esquerda**: vai para a variante anterior (dá a volta).
- **Rótulo da variante**: mostra a chave da variante atual e, se a variante exportar um nome, esse nome também. Por exemplo, `B (Sidebar layout)`.
- **Seta direita**: avança (dá a volta).

Comportamento:

- Clicar em uma seta atualiza o parâmetro de busca na URL (use o roteador do framework, por exemplo `router.replace` no Next, `navigate` no React Router etc.), para que a variante seja compartilhável e se mantenha ao recarregar.
- Teclado: as teclas `←` e `→` também alternam. Não intercepte as teclas de seta quando um `<input>`, `<textarea>` ou `[contenteditable]` estiver com o foco.
- Visualmente distinto da página (por exemplo, uma pílula de alto contraste, uma sombra sutil), para que fique óbvio que não faz parte do design em avaliação.
- Oculto em builds de produção: condicione a `process.env.NODE_ENV !== 'production'` ou a uma checagem equivalente, para que um merge acidental de protótipo não envie a barra aos usuários.

Coloque o seletor em um único componente compartilhado, para que os dois subformatos possam reutilizá-lo. Localize-o onde o projeto guarda a UI compartilhada.

### 5. Entregue

Informe a URL (e as chaves `?variant=`). O usuário vai percorrer quando tiver tempo. O feedback mais interessante costuma ser **"quero o cabeçalho da B com a barra lateral da C"**, que é justamente o design que ele quer.

### 6. Registre a resposta e faça a limpeza

Quando uma variante vencer, registre a resposta (qual variante e por quê) e, em seguida, registre o protótipo do jeito que o [SKILL](TRADUCAO.pt-BR.md) descreve. Incorpore a vencedora ao código real e mova as demais para o branch descartável, não para a main:

- **Subformato A**: incorpore a vencedora à página existente; remova da main as variantes perdedoras e o seletor.
- **Subformato B**: promova a variante vencedora a uma rota real; remova da main a rota descartável e o seletor.

O conjunto completo de variantes é a fonte primária, então ele vai para o branch descartável, e não para o lixo, já que componentes de variante e o seletor deixados na branch main apodrecem rápido e confundem o próximo leitor.

## Anti-padrões

- **Variantes que diferem só em cor ou texto.** Isso é um ajuste, não um protótipo. Variantes de verdade discordam sobre a estrutura.
- **Compartilhar código demais entre variantes.** Um `<Header>` compartilhado é aceitável; um `<Layout>` compartilhado anula o objetivo. Cada variante precisa ser livre para descartar o layout.
- **Conectar as variantes a mutações reais.** Protótipos somente leitura são aceitáveis. Se uma variante precisar mutar, aponte-a para um stub: a pergunta é "como isto deveria parecer", não "o backend funciona".
- **Promover o protótipo diretamente para produção.** O código das variantes foi escrito sob as restrições do protótipo (sem testes, tratamento de erro mínimo). Reescreva-o direito ao incorporá-lo.
