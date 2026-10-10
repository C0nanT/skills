```yaml
name: grill-with-docs
description: Uma entrevista implacável para aprimorar um plano ou design, que também cria documentos (ADRs e glossário) ao longo do caminho.
disable-model-invocation: true
```

Chame a ferramenta Skill com "grilling". À medida que as decisões se consolidam, construa e aprimore os documentos de domínio do projeto em paralelo: acrescente ou refine termos do glossário em `GLOSSARY.md` e registre as decisões de trade-off relevantes como ADRs em `docs/adr/`.

Esses documentos são os únicos arquivos que a sessão escreve. O assunto é a própria funcionalidade: o que ela faz, para quem é e as decisões por trás dela. Escrever o trabalho é tarefa de outra skill. `to-spec` escreve a especificação, `to-tickets` escreve os tickets. Quando a fronteira estiver vazia, diga que a funcionalidade está pronta para uma dessas duas e pare aí.

Fale em linguagem simples. Prefira a palavra do dia a dia à palavra técnica, escreva um termo por extenso na primeira vez em que ele aparecer e acrescente uma explicação de uma linha sempre que um nome puder não fazer sentido para o usuário.
