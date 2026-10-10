# Eixos

O que cada subagente procura e como classificar o que encontra. Leia apenas as seções que o seu despacho nomear.

Cada eixo lista **sinais**: as formas que valem a pena olhar. Um sinal é um motivo para abrir o arquivo, não um achado. O que transforma um sinal em achado é o **custo**: a coisa concreta que fica mais difícil, mais lenta ou mais arriscada porque o código é assim. Tudo a que você não consegue atribuir um custo pertence ao ruído de fundo, não ao mapa.

## Architecture

Sinais:

- Um módulo que concentra responsabilidades que mudam por motivos não relacionados.
- Dependências circulares, e ciclos de import que o build tolera.
- Lógica de negócio morando em código de transporte (controllers, handlers, componentes) ou na camada de persistência.
- A mesma lógica implementada em duas camadas, cada uma sem saber da outra.
- Dois ou mais padrões arquiteturais em uso para o mesmo tipo de problema, de modo que quem chega não consegue saber qual seguir.
- Uma abstração com uma única implementação e nenhuma substituição em lugar nenhum, ou um conceito que claramente pede uma e não tem nenhuma.

O achado de arquitetura mais forte nomeia uma **mudança que deveria ser local e não é**.

## Code

Sinais:

- Funções e classes longas o bastante para que ninguém as leia de cima a baixo.
- Lógica duplicada, especialmente cópias que já divergiram.
- Condicionais que precisam de um quadro branco: aninhamento profundo, cadeias longas de booleanos, argumentos-flag que bifurcam o corpo inteiro.
- Valores mágicos, e constantes que significam a mesma coisa definidas em vários lugares.
- Nomes que enganam (um `get` que escreve, um `Manager` que é um saco de helpers sem relação entre si).
- Tratamento de erro que varia de arquivo para arquivo: exceções engolidas, erro logado e seguido adiante, strings lançadas.
- Código morto, e blocos comentados mantidos "por precaução".
- Comentários que explicam o que o código faz, quando um renomear teria dito isso.
- Correções temporárias que sobreviveram ao motivo (`TODO`, `HACK`, um contorno para um bug corrigido upstream dois anos atrás).

## Business rules

O eixo de maior valor em uma base de código que cresceu de forma orgânica, porque estes achados são os que ninguém consegue reconstruir só a partir do código.

Sinais:

- A mesma regra implementada em mais de um lugar, com qualquer divergência entre as cópias.
- Regras enterradas em um controller, um componente, um trigger ou um job de cron.
- Comportamento que depende da ordem de execução, ou de um efeito colateral que acontece antes.
- Exceções tratadas por um caso especial pendurado em um caminho geral.
- Limiares, cortes e códigos que parecem arbitrários.
- O mesmo conceito respondido de forma diferente em duas partes do sistema.

Para cada regra que encontrar, diga **onde ela mora e o que depende dela**. Quando ela parecer errada mas puder ser um requisito real, marque-a como `needs-validation` e escreva a pergunta a fazer, em vez de chamá-la de bug.

## Maintainability

Sinais:

- Uma mudança de uma linha que exige edições em vários arquivos, e a lista de arquivos não é descobrível.
- Acoplamento implícito: um objeto mutável compartilhado, uma global, uma variável de ambiente lida no fundo da pilha.
- Baixa coesão: um módulo cujas partes não têm nada a ver umas com as outras.
- Um componente amplamente reutilizado que ganhou uma prop ou flag por chamador.
- Efeitos colaterais em código que parece um cálculo puro.

O teste: escolha uma próxima mudança plausível e rastreie o que ela toca. Esse rastro é a evidência.

## Testability

Sinais:

- Lógica arriscada ou complexa sem nenhum teste.
- Lógica alcançável somente através de infraestrutura (um banco ativo, uma chamada HTTP real, um relógio, um sistema de arquivos).
- Construtores ou corpos de módulo que fazem trabalho, de modo que nada pode ser instanciado isoladamente.
- Dependências que não podem ser substituídas, então um teste precisa do mundo inteiro.
- Testes que fazem asserções sobre detalhes de implementação e quebram a cada refatoração.

Testes ausentes não são um achado por si só. Um achado é **código sem teste que carrega risco**: dinheiro, autenticação, perda de dados, ou as regras do eixo Business rules.

## Performance

Sinais:

- Consultas N+1, e consultas dentro de laços.
- O mesmo trabalho repetido dentro de uma requisição, ou entre requisições, sem memoização nem cache.
- Carregar coleções inteiras para usar um campo, ou para contá-las.
- Chamadas externas que poderiam ser agrupadas, paralelizadas ou evitadas.
- Trabalho feito no lugar errado: no app o que o banco de dados faz melhor, em uma requisição o que um job deveria fazer.

Relate o que está comprovadamente ou estruturalmente errado, e diga qual. Um sinal sem evidência de carga por trás é uma nota, não um achado: otimização prematura também é dívida.

## Security and robustness

Sinais:

- Entrada confiada em uma fronteira: payloads não validados, parâmetros interpolados em consultas ou comandos.
- Autorização verificada em alguns caminhos e não em outros, ou verificada só na interface.
- Dados superexpostos por um endpoint ou um serializador (campos internos, registros de outros usuários).
- Segredos, tokens ou credenciais no código-fonte ou em configuração versionada.
- Erros que vazam detalhes internos para o cliente, ou que escondem falhas dos logs.
- Dependências sem manutenção, muito desatualizadas, ou usadas em um modo inseguro.

## Rubrics

**Gravidade**, quanto isso custa hoje:

| | | |
| - | - | - |
| 🔴 | Critical | Causando bugs, risco de dados ou exposição de segurança agora, ou bloqueando trabalho já agendado. |
| 🟠 | High | Retarda ou põe em risco de forma confiável as mudanças em uma área que continua mudando. |
| 🟡 | Medium | Custo real, em código que raramente muda. |
| 🟢 | Low | Convenção ou clareza. Vale a pena fazer ao passar por ali. |

**Raio de impacto**, quantos lugares precisam se mover juntos:

| | |
| - | - |
| Contained | A correção cabe dentro dos próprios arquivos do módulo. |
| Module+ | Chamadores ou chamados precisam mudar junto. |
| Systemic | Exige uma decisão de design, ou uma mudança coordenada entre equipes. |

Classifique lendo o código, não adivinhando quanto tempo levaria para alguém. Quantos lugares se movem é um fato que o repositório consegue responder; quantos dias custa depende de quem faz e do que mais está pegando fogo.

**Retorno**, o que a correção traz: **High** elimina uma classe de bug ou destrava uma área inteira, **Medium** torna uma área significativamente mais fácil, **Low** é uma melhoria local.

Ordene o mapa por retorno em relação ao raio de impacto, não por gravidade: um 🟠 que é Contained com retorno High fica acima de um 🔴 que é Systemic. Essa ordenação afunda de propósito os maiores problemas, então a linha de fechamento do mapa nomeia as linhas a limpar antes da próxima funcionalidade, que é onde um 🔴 afundado volta à tona.
