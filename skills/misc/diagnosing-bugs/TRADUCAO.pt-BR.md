```yaml
name: diagnosing-bugs
description: Ciclo de diagnóstico para bugs difíceis e regressões de performance. Use quando o usuário disser "diagnose"/"debug this", ou relatar algo quebrado, com erro, falhando ou lento.
```

# Diagnosticar bugs

Uma disciplina para bugs difíceis. Pule fases somente com uma justificativa explícita.

Ao explorar a base de código, leia o `GLOSSARY.md` (se existir) para ter um modelo mental claro dos módulos relevantes, e verifique os ADRs da área que você está tocando.

## Redigir

Esta skill faz você mostrar comandos, saídas e artefatos capturados. **Redija todo segredo antes**: escreva `<REDACTED>` no lugar. Construa os loops com variáveis de ambiente, para que a credencial fique no ambiente e não no que você mostra. Artefatos capturados trazem cabeçalhos de autenticação: cite apenas as linhas que carregam o sinal.

Se a saída redigida não for suficiente para diagnosticar o bug, diga isso e pergunte ao usuário.

## Fase 1: construir um loop de feedback

**Esta é a skill.** Todo o resto é mecânico. Se você tem um sinal **apertado** de passa/falha para o bug (um que fique vermelho *neste* bug), você vai encontrar a causa; bisseção, teste de hipóteses e instrumentação apenas consomem esse sinal. Se você não tem um, nenhuma quantidade de olhar para o código vai salvar você.

Dedique esforço desproporcional aqui. **Seja agressivo. Seja criativo. Recuse-se a desistir.**

### Formas de construir um, aproximadamente nesta ordem

1. **Teste que falha** no seam que alcança o bug: unitário, integração, e2e.
2. **Script de curl / HTTP** contra um servidor de desenvolvimento em execução.
3. **Invocação de CLI** com uma entrada de fixture, comparando a stdout com um snapshot conhecido como bom.
4. **Script de navegador headless** (Playwright / Puppeteer) que dirige a UI e faz asserções sobre DOM/console/rede.
5. **Reproduzir um trace capturado.** Salve em disco uma requisição de rede / payload / log de eventos real; reproduza-o pelo caminho de código isoladamente.
6. **Arnês descartável.** Suba um subconjunto mínimo do sistema (um serviço, dependências mockadas) que exercite o caminho de código do bug com uma única chamada de função.
7. **Loop de propriedade / fuzz.** Se o bug é "às vezes a saída está errada", rode 1000 entradas aleatórias e procure o modo de falha.
8. **Arnês de bisseção.** Se o bug apareceu entre dois estados conhecidos (commit, dataset, versão), automatize "suba no estado X, verifique, repita" para poder rodar `git bisect run`.
9. **Loop diferencial.** Rode a mesma entrada pela versão antiga e pela nova (ou por duas configurações) e compare as saídas.
10. **Script bash HITL.** Último recurso. Se um humano precisa clicar, conduza *ele* com `scripts/hitl-loop.template.sh`, para que o loop continue estruturado. A saída capturada volta para você.

Construa o loop de feedback certo, e o bug está 90% resolvido.

### Aperte o loop

Trate o loop como um produto. Depois de ter *um* loop, **aperte-o**:

- Consigo deixá-lo mais rápido? (Cachear a configuração, pular inicializações não relacionadas, estreitar o escopo do teste.)
- Consigo tornar o sinal mais nítido? (Fazer asserção sobre o sintoma específico, não sobre "não travou".)
- Consigo torná-lo mais determinístico? (Fixar o tempo, semear o RNG, isolar o sistema de arquivos, congelar a rede.)

Um loop de 30 segundos e instável quase não é melhor do que nenhum loop; um de 2 segundos e determinístico é apertado, um superpoder de depuração.

### Bugs não determinísticos

O objetivo não é uma reprodução limpa, mas uma **taxa de reprodução maior**. Repita o gatilho 100×, paralelize, aumente o estresse, estreite as janelas de tempo, injete esperas. Um bug que falha 50% das vezes é depurável; um de 1% não é, então continue aumentando a taxa até ele ficar depurável.

### Quando você genuinamente não consegue construir um loop

Pare e diga isso explicitamente. Liste o que tentou. Peça ao usuário: (a) acesso ao ambiente que reproduz o bug, (b) um artefato capturado e redigido (arquivo HAR, dump de log, core dump, gravação de tela com timestamps), ou (c) permissão para adicionar instrumentação temporária em produção. **Não** prossiga para hipóteses sem um loop.

### Critério de conclusão: um loop apertado que fica vermelho

A Fase 1 termina quando o loop está **apertado** e **capaz de ficar vermelho**: você consegue nomear **um comando** (um caminho de script, uma invocação de teste, um curl) que você **já rodou ao menos uma vez** (mostre a invocação e a saída, redigidas), e que é:

- [ ] **Capaz de ficar vermelho**: ele percorre o caminho de código real do bug e faz asserção sobre o **sintoma exato do usuário**, então pode ficar vermelho neste bug e verde depois de corrigido. Não "roda sem dar erro"; ele precisa ser capaz de *pegar este bug específico*.
- [ ] **Determinístico**: o mesmo veredito a cada execução (bugs instáveis: uma taxa de reprodução fixa e alta, como acima).
- [ ] **Rápido**: segundos, não minutos.
- [ ] **Executável pelo agente**: você consegue rodá-lo sem supervisão; um humano no loop só pelo `scripts/hitl-loop.template.sh`.

Se você se pegar lendo código para construir uma teoria antes de esse comando existir, **pare: pular direto para uma hipótese é exatamente a falha que esta skill evita.** Sem um comando capaz de ficar vermelho, não há Fase 2.

## Fase 2: reproduzir + minimizar

Rode o loop. Observe-o ficar vermelho conforme o bug aparece.

Confirme:

- [ ] O loop produz o modo de falha que o **usuário** descreveu, não uma falha diferente que acontece estar por perto. Bug errado = correção errada.
- [ ] A falha é reproduzível em várias execuções (ou, para bugs não determinísticos, reproduzível numa taxa alta o bastante para depurar).
- [ ] Você capturou o sintoma exato (mensagem de erro, saída errada, tempo lento) para que as fases seguintes possam verificar se a correção realmente o resolve.

### Minimizar

Quando ele já está vermelho, encolha a reprodução até o **menor cenário que ainda fica vermelho**. Corte entradas, chamadores, configuração, dados e passos **um de cada vez**, rodando o loop depois de cada corte, e mantenha apenas o que sustenta a falha.

Por que se dar ao trabalho: uma reprodução mínima reduz o espaço de hipóteses na Fase 3 (menos partes móveis para suspeitar) e vira o teste de regressão limpo na Fase 5.

Pronto quando **cada elemento restante sustenta o resultado**: remover qualquer um deles faz o loop ficar verde.

Não prossiga até ter reproduzido **e** minimizado.

## Fase 3: formular hipóteses

Gere **de 3 a 5 hipóteses ordenadas** antes de testar qualquer uma delas. Gerar uma única hipótese se ancora na primeira ideia plausível.

Cada hipótese precisa ser **refutável**: enuncie a previsão que ela faz.

> Formato: "Se <X> é a causa, então <mudar Y> fará o bug desaparecer / <mudar Z> o fará piorar."

Se você não consegue enunciar a previsão, a hipótese é um palpite: descarte-a ou afie-a.

**Mostre a lista ordenada ao usuário antes de testar.** Ele costuma ter conhecimento de domínio que reordena tudo na hora ("acabamos de subir uma mudança no #3"), ou conhece hipóteses que já descartou. É um checkpoint barato e que economiza muito tempo. Não bloqueie por isso; siga com a sua ordenação se o usuário estiver AFK.

## Fase 4: instrumentar

Cada sonda precisa corresponder a uma previsão específica da Fase 3. **Mude uma variável por vez.**

Preferência de ferramenta:

1. **Inspeção com depurador / REPL**, se o ambiente permitir. Um breakpoint vale mais do que dez logs.
2. **Logs direcionados** nas fronteiras que distinguem as hipóteses.
3. Nunca "logar tudo e fazer grep".

**Marque todo log de depuração** com um prefixo único, por exemplo `[DEBUG-a4f2]`. A limpeza no fim vira um único grep. Logs sem marca sobrevivem; logs marcados morrem.

**Ramo de performance.** Para regressões de performance, logs costumam ser o instrumento errado. Em vez disso: estabeleça uma medição de linha de base (harness de tempo, `performance.now()`, profiler, plano de consulta) e depois faça bisseção. Meça primeiro, corrija depois.

## Fase 5: corrigir + teste de regressão

Escreva o teste de regressão **antes da correção**, mas só se existir um **seam correto** para ele.

Um seam correto é aquele em que o teste exercita o **padrão real do bug** como ele ocorre no ponto de chamada. Se o único seam disponível for raso demais (um teste de chamador único quando o bug precisa de vários chamadores, um teste unitário que não consegue replicar a cadeia que disparou o bug), um teste de regressão ali dá falsa confiança.

**Se não existe seam correto, isso em si é o achado.** Anote. A arquitetura da base de código está impedindo que o bug seja travado. Sinalize isso para a fase seguinte.

Se existir um seam correto:

1. Transforme a reprodução minimizada em um teste que falha nesse seam.
2. Veja-o falhar. Se você forçou o vermelho mutando código ou uma fixture, faça `diff` contra uma cópia intacta para provar que a mutação aconteceu antes de confiar nela.
3. Aplique a correção.
4. Veja-o passar.
5. Rode de novo o loop de feedback da Fase 1 contra o cenário original (não minimizado).

## Fase 6: limpeza

Obrigatório antes de declarar concluído:

- [ ] A reprodução original não reproduz mais (rode de novo o loop da Fase 1)
- [ ] O teste de regressão passa (ou a ausência de seam está documentada)
- [ ] Toda instrumentação `[DEBUG-...]` foi removida (`grep` no prefixo)
- [ ] Protótipos descartáveis apagados (ou movidos para um local de depuração claramente marcado)
- [ ] A hipótese que se revelou correta está declarada na mensagem do commit / PR, para que o próximo depurador aprenda com ela
