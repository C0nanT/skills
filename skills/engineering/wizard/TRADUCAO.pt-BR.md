```yaml
name: wizard
description: Gere um wizard interativo em bash que guia uma pessoa por passos que só ela consegue executar. Use ao provisionar infraestrutura, configurar credenciais ou secrets de CI, percorrer um painel de terceiros desconhecido, ou executar uma migração ou troca pontual. Não invoque para passos que o agente consegue executar sozinho.
```

# Wizard

Um **wizard** é um script bash que guia uma pessoa, passo a passo, por um procedimento manual que é cansativo de fazer à mão e cansativo de explicar de novo para uma IA a cada vez. Ele abre cada URL, diz exatamente o que clicar e copiar, captura os valores, grava-os onde devem ficar (`.env`, secrets do GitHub), confirma em cada etapa e mostra quantas etapas ainda faltam. Ele pode configurar serviços de terceiros, executar uma migração pontual ou levar o projeto de um estado para outro.

A experiência de uso já está resolvida pelo [template.sh](template.sh): progresso por etapa, portões de confirmação, abertura de URL multiplataforma (incluindo WSL), entrada oculta de secrets, upserts idempotentes no `.env`, escritas com `gh secret`/`gh variable` e um resumo final. **Seu trabalho é apenas definir o escopo do procedimento e escrever as etapas.** A biblioteca acima do marcador `STAGES` é idêntica em todo wizard; essa consistência é o objetivo: nunca a edite à mão.

Por padrão, um wizard é efêmero: feito para uma única execução, salvo em um caminho temporário ou em `scripts/`, e apagado quando o trabalho termina. Faça commit dele somente quando o usuário quiser um caminho de configuração repetível que deva ficar no repositório.

## Processo

### 1. Definir o escopo do procedimento

Descubra cada passo manual que a pessoa precisa dar e cada valor capturado no caminho. Leia o repositório primeiro, não pergunte às cegas:

- Para configuração: `.env`, `.env.example`, `.env.*`, `README`, `docker-compose*`, a configuração do framework e `.github/workflows/*` (toda referência a `secrets.*` / `vars.*` é um valor que o wizard precisa produzir).
- Para uma migração ou transição: o estado atual, o estado alvo e as ações irreversíveis entre eles.

Em seguida, mostre ao usuário a lista ordenada de etapas e os valores que cada uma produz, e peça confirmação: ele pode adicionar, remover ou reordenar.

**Pronto quando:** cada etapa está nomeada na ordem, e, para cada valor capturado, você sabe (a) onde a pessoa o obtém, (b) onde ele é gravado (`.env`, um secret do GitHub, ambos ou em lugar nenhum; algumas etapas são apenas ações) e (c) se é secreto (entrada oculta) ou público.

### 2. Mapear o percurso de cada etapa

Para cada etapa, escreva o caminho preciso que a pessoa segue: qual URL abrir, o que fazer ali, onde um valor é mostrado, qual variável ele preenche. Por exemplo: "Dashboard → Developers → API keys → Reveal test key → copy". Quando você não souber de fato a interface atual ou o comando exato, diga isso e pergunte ao usuário ou consulte a documentação: nunca invente passos que talvez não existam.

**Pronto quando:** cada etapa leva a instruções concretas que um desconhecido conseguiria seguir.

### 3. Escrever o wizard

Copie o `template.sh` para o caminho de destino. Substitua a etapa de exemplo por uma `stage` para cada passo, em ordem de dependência. Use os helpers da biblioteca: `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm`. Defina `TOTAL_STAGES` com o número de etapas que você escreveu.

Mantenha o padrão que o template estabelece: abra a URL antes de pedir o valor dela, use `ask_secret` para qualquer coisa secreta, use `write_env` para todo valor persistido, use `set_secret` apenas para os valores que o CI realmente precisa e use `confirm` antes de qualquer ação irreversível. Cada `stage` limpa a tela para que só a etapa atual seja visível: mantenha cada etapa com uma única tarefa focada, para que nada que a pessoa precise saia da tela. Não mexa na biblioteca acima do marcador.

### 4. Verificar e entregar

- `bash -n <script>`; rode `shellcheck` se estiver disponível.
- `chmod +x <script>`.
- Não execute o script de ponta a ponta você mesmo: ele abre navegadores e fica bloqueado esperando a entrada humana. Em vez disso, verifique estaticamente: cada valor do passo 1 é capturado e cai onde o passo 1 disse, e cada nome de `set_secret` corresponde exatamente a uma referência `secrets.*` no CI.
- ENV_FILE está no gitignore: o `write_env` da biblioteca pergunta antes da primeira escrita quando ele não está, mas um wizard que define `ENV_FILE` com um caminho não padrão deve apontar para um arquivo que o repositório ignora.
- Diga ao usuário como executá-lo. Se for um caminho de configuração repetível, faça commit dele e linke-o a partir do README, para que a próxima pessoa execute o script em vez de perguntar a uma IA.
