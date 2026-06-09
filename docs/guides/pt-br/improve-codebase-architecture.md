# `/improve-codebase-architecture` — Melhoria Arquitetural da Codebase

## O que é

Uma skill que analisa sua codebase em busca de oportunidades de "aprofundamento" — refatorações que transformam módulos rasos (shallow) em módulos profundos (deep), tornando o código mais testável e navegável por IAs.

## Para que serve

- Quando o projeto virou uma "bola de lama" e você não sabe por onde começar
- Para identificar módulos fortemente acoplados que deveriam ter interfaces claras
- Para encontrar código difícil de testar
- Para tornar a codebase mais fácil de navegar (para você e para o agente)
- Recomendado rodar a cada poucos dias em projetos ativos

## Como invocar

```
/improve-codebase-architecture
```

## Como funciona

### Vocabulário da skill

A skill usa terminologia específica e consistente:

- **Módulo** — qualquer coisa com uma interface e uma implementação
- **Profundidade (Depth)** — quanto comportamento fica escondido atrás de uma interface pequena. Módulo profundo = muito comportamento por interface simples. Módulo raso = interface quase tão complexa quanto a implementação
- **Seam** — onde uma interface vive; lugar onde comportamento pode ser alterado sem editar o código diretamente
- **Leverage** — o que os callers ganham com a profundidade de um módulo

**Teste da deleção**: imagine deletar o módulo. Se a complexidade desaparece, era um pass-through inútil. Se a complexidade reaparece espalhada em N callers, o módulo estava ganhando seu lugar.

### Processo

**1. Exploração**

Lê o `CONTEXT.md` e ADRs primeiro. Depois navega a codebase organicamente, procurando por:
- Onde entender um conceito exige pular entre muitos módulos pequenos?
- Onde módulos são rasos (a interface é quase tão complexa quanto a implementação)?
- Onde o código é difícil de testar?
- Onde módulos acoplados vazam através das suas interfaces?

**2. Relatório HTML**

Gera um arquivo HTML visual com Tailwind e Mermaid, salvo em `/tmp/architecture-review-<timestamp>.html` e aberto automaticamente no browser. Para cada candidato de refatoração, o relatório mostra:
- Quais arquivos estão envolvidos
- Por que a arquitetura atual causa atrito
- O que mudaria
- Benefícios em termos de localidade e leverage
- Diagrama antes/depois desenhado visualmente
- Força da recomendação: `Strong`, `Worth exploring`, ou `Speculative`

O relatório termina com uma seção "Top recommendation" — qual candidato atacar primeiro e por quê.

**3. Loop de grilling**

Quando você escolhe um candidato, a skill entra em modo de entrevista para trabalhar o design: constraints, dependências, forma do módulo aprofundado, o que fica atrás do seam, que testes sobrevivem.

Efeitos colaterais durante o grilling:
- Novos termos são adicionados ao `CONTEXT.md` inline
- Decisões de rejeição com motivo forte geram oferta de ADR

## Exemplo de uso

```
A codebase tá crescendo rápido e ficando difícil de mudar. Quero ver onde posso melhorar a arquitetura.

/improve-codebase-architecture
```

O agente vai explorar, gerar o relatório HTML, você abre no browser, escolhe um candidato, e entram num loop de conversa para trabalhar o design da refatoração.

## Dicas

- Rode periodicamente, não só quando o projeto já está problemático
- O relatório abre automaticamente no browser — procure o path no output caso não abra
- A skill não propõe interfaces novas até você escolher um candidato — evita desperdício de tokens
- Contradições com ADRs existentes são marcadas no relatório com um aviso, não ignoradas silenciosamente
