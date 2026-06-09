# `/prototype` — Construção de Protótipo Descartável

## O que é

Uma skill que constrói protótipos descartáveis para validar um design antes de se comprometer com a implementação real. O protótipo responde uma pergunta específica — e depois é deletado.

## Para que serve

- Quando você não tem certeza se um modelo de estado ou state machine vai funcionar
- Quando quer ver como uma UI vai parecer antes de implementar de verdade
- Quando tem opções de design e quer explorar variações antes de escolher
- Quando quer "brincar" com uma ideia antes de transformá-la em código de produção
- Qualquer situação em que "deixa eu tentar antes de decidir" faz sentido

## Como invocar

```
/prototype
```

Descreva o que você quer explorar. A skill vai identificar qual tipo de protótipo faz sentido.

## Como funciona

A skill escolhe entre dois ramos:

### Ramo 1: Lógica/Estado — `LOGIC.md`

**Pergunta sendo respondida**: "Esse modelo de dados / state machine faz sentido?"

Constrói um **app terminal interativo e minimalista** que permite navegar pelo state machine manualmente, testando casos difíceis de raciocinar no papel.

Características:
- Roda com um comando (ex: `pnpm prototype`)
- Sem persistência — estado vive na memória
- Exibe o estado completo após cada ação
- Descartável do dia um

### Ramo 2: UI — `UI.md`

**Pergunta sendo respondida**: "Como isso deve parecer?"

Gera **várias variações radicalmente diferentes** de UI numa única rota, alternáveis via parâmetro de URL e uma barra flutuante na tela.

Características:
- Sem banco de dados, sem autenticação — só UI
- Múltiplas variações visualmente distintas na mesma rota
- Obedece a estrutura de roteamento do projeto existente
- Não inventa estrutura nova de pastas

### Regras comuns a ambos

1. **Código claramente marcado como protótipo** — nome que avisa que não é produção
2. **Um comando para rodar** — sem configuração
3. **Sem polimento** — sem testes, sem error handling além do necessário para rodar, sem abstrações
4. **Exibe o estado** — após cada ação (lógica) ou em cada troca de variante (UI)
5. **Deletar ou absorver quando pronto** — não deixar apodrecendo no repo

### Quando terminar

O único artefato que vale manter é a **resposta** à pergunta que o protótipo estava respondendo. Captura isso num commit message, ADR, issue, ou num `NOTES.md` ao lado do protótipo — e então deleta o protótipo.

## Exemplo de uso

```
Quero prototipar o fluxo de checkout com múltiplos passos. Não tenho certeza se o estado deve ficar num contexto global ou num state machine local por etapa.

/prototype
```

A skill vai para o ramo de lógica e constrói um terminal app que simula o checkout, permitindo avançar/voltar etapas e ver o estado exibido a cada passo.

```
Quero explorar como a página de configurações deve ser organizada. Tenho 3 ideias diferentes.

/prototype
```

A skill vai para o ramo de UI e gera as 3 variações numa única rota, com toggle entre elas.
