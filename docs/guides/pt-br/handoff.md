# `/handoff` — Documento de Handoff para Próxima Sessão

## O que é

Uma skill que compacta a conversa atual em um documento de handoff estruturado, salvo no diretório temporário do sistema, para que um agente novo (ou você numa nova sessão) possa continuar o trabalho de onde parou.

## Para que serve

- Quando a sessão está chegando no limite de contexto
- Quando você quer continuar o trabalho em outra sessão ou em outro terminal
- Quando quer passar trabalho para outro agente ou outra pessoa
- Para preservar o contexto de decisões tomadas antes que seja perdido

## Como invocar

```
/handoff
```

Com argumento (descreve o foco da próxima sessão):

```
/handoff Continuar implementação do sistema de notificações
/handoff Testar e debugar o fluxo de checkout
```

## Como funciona

O agente cria um documento Markdown com:

**Contexto da conversa** — resumo do que foi discutido, decidido, e construído.

**Estado atual** — onde o trabalho está agora: o que está pronto, o que está em progresso, o que está pendente.

**Referências** — em vez de duplicar conteúdo que já existe em outros artefatos (specs, planos, ADRs, issues, commits, diffs), o documento *referencia* eles por path ou URL.

**Skills sugeridas** — seção que recomenda quais skills o próximo agente deve invocar para continuar o trabalho. Por exemplo: "Invoque `/tdd` para implementar a issue #45" ou "Use `/diagnosing-bugs` para investigar o bug de race condition mencionado."

**Informações sensíveis** são redatadas automaticamente — API keys, senhas, PII não aparecem no documento.

O arquivo é salvo no diretório temporário do sistema (`/tmp` no Linux/Mac, `%TEMP%` no Windows) — não na workspace, para não poluir o repositório.

## Exemplo de uso

```
Vamos parar por aqui. Preciso continuar amanhã.

/handoff Retomar implementação do módulo de pagamentos
```

O agente vai criar algo como `/tmp/handoff-2026-06-08-payments.md` com:
- Resumo do que foi decidido sobre a integração de pagamentos
- Referência ao spec publicado na issue #23
- Estado: "OrderService interface definida, ainda falta implementar RefundProcessor"
- Skills sugeridas: "Invoque `/tdd` para implementar RefundProcessor seguindo a interface definida"

## Dicas

- O argumento após `/handoff` é tratado como descrição do foco da próxima sessão — o documento é ajustado para ser mais útil para aquele objetivo específico
- O documento é salvo no temp dir e **não** no projeto — se quiser preservar permanentemente, copie manualmente
- Não duplica o que está em commits, specs ou issues existentes — apenas referencia
