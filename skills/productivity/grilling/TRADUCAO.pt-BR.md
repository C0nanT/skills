```yaml
name: grilling
description: Submeta o usuário a perguntas implacáveis sobre um plano, decisão ou ideia. Use quando o usuário quiser testar o próprio raciocínio, ou usar qualquer frase de gatilho com "grill".
```

Entreviste o usuário de forma implacável até chegar a um entendimento compartilhado. Mapeie isso como uma **árvore de design**: cada decisão se ramifica nas decisões que dependem dela.

Trabalhe a árvore em **rodadas**. A **fronteira** é o conjunto de todas as decisões cujos pré-requisitos já estão resolvidos: as perguntas que você pode fazer _agora_ sem chutar respostas que ainda não ouviu. Faça a fronteira inteira em uma única rodada: numere cada pergunta e dê a sua resposta recomendada. Depois, espere as respostas do usuário antes da próxima rodada.

Formate uma rodada assim:

```markdown
❓ **Q1** - **<título da pergunta>**: <corpo da pergunta, pode ter vários parágrafos, incluindo múltiplas escolhas>

➡️ <sua resposta recomendada>

---

❓ **Q2** - **<título da pergunta>**: <corpo da pergunta, pode ter vários parágrafos, incluindo múltiplas escolhas>

➡️ <sua resposta recomendada>
```

Redija cada pergunta de modo que um "sim" aceite a sua resposta recomendada.

Cada resposta do usuário remodela a árvore: decisões resolvidas empurram a fronteira para fora e destravam perguntas que dependiam delas. Recalcule a fronteira e faça a próxima rodada. Uma pergunta cuja resposta depende de outra pergunta ainda aberta nesta rodada pertence a uma rodada _posterior_, não a esta.

Encontrar _fatos_ é tarefa sua, nunca do usuário. Quando uma pergunta da fronteira depender de um fato do ambiente (sistema de arquivos, ferramentas etc.), despache um subagente para encontrá-lo; não peça ao usuário nada que você mesmo possa consultar. Não fique bloqueado por isso: uma exploração em andamento é um pré-requisito não resolvido, então apenas as perguntas que dependem dela aguardam o relatório do subagente; faça agora o restante da fronteira. As _decisões_ são do usuário: apresente cada uma a ele e espere.

A sessão termina quando a fronteira estiver vazia: cada ramo da árvore de design foi visitado, e nada foi deixado assumido em silêncio. Não aja com base nela até que o usuário confirme que chegaram a um entendimento compartilhado.
