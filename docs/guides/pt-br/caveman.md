# `/caveman` — Modo de Comunicação Ultra-Comprimido

## O que é

Uma skill de produtividade que ativa um modo de comunicação ultra-comprimido. O agente passa a falar como um "caveman esperto" — mantém toda a substância técnica, mas corta artigos, preenchimentos, gentilezas e hedging. Reduz o uso de tokens em ~75%.

## Para que serve

- Quando você quer respostas mais rápidas e diretas
- Para economizar tokens em sessões longas
- Quando você já é experiente no assunto e não precisa de explicações longas
- Para qualquer momento em que verbosidade está atrapalhando a produtividade

## Como invocar

```
/caveman
```

Ou simplesmente dizer: "caveman mode", "less tokens", "be brief", "fala como caveman".

Para desativar:
```
stop caveman
normal mode
```

## Como funciona

Uma vez ativado, o agente:

**Dropa:**
- Artigos (a, an, the)
- Preenchimentos (just, really, basically, actually, simply)
- Gentilezas (sure, certainly, of course, happy to)
- Hedging (might, perhaps, potentially)
- Conjunções desnecessárias

**Mantém:**
- Todos os termos técnicos exatos
- Code blocks sem alteração
- Erros citados exatamente

**Usa:**
- Fragmentos de frase quando suficiente
- Sinônimos curtos (big não "extensive", fix não "implement a solution for")
- Abreviações comuns (DB, auth, config, req, res, fn, impl)
- Setas para causalidade (X → Y)
- Uma palavra quando uma palavra é suficiente

**Padrão:** `[coisa] [ação] [razão]. [próximo passo].`

### Exemplos

**Modo normal:**
> "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by a problem in the authentication middleware where the token expiry check is using the wrong comparison operator..."

**Modo caveman:**
> "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

### Exceção de clareza automática

O caveman mode é suspenso temporariamente para:
- Avisos de segurança
- Confirmações de ações irreversíveis
- Sequências multi-passo onde fragmentos podem causar leitura errada
- Quando o usuário pede para clarificar ou repete a pergunta

Depois da parte crítica, o modo caveman retoma automaticamente.

## Persistência

Uma vez ativado, persiste **em todas as respostas** da sessão. Não reverte com o tempo. Só desativa quando você explicitamente diz "stop caveman" ou "normal mode".

## Dica

Útil combinar com sessões de `/tdd` ou `/diagnose` longas onde você quer respostas técnicas rápidas sem prosa extra.
