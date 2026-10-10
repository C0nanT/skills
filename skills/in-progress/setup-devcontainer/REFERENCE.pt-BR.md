# Referência: o devcontainer que herda a identidade do host

O padrão por trás do `setup-devcontainer`: o que é decisão, o que é consequência e onde ele varia de acordo com a stack. Tudo aqui existe porque a alternativa óbvia falha de um jeito cuja mensagem de erro não nomeia a causa.

## 1. O devcontainer é um serviço do Compose

Um serviço chamado `workspace` no arquivo de override de desenvolvimento, atrás de um profile (`dev-tools`) para que um `docker compose up` normal não o inicie. O `.devcontainer/devcontainer.json` aponta para os arquivos Compose e nomeia esse serviço.

**Por quê:** dentro da rede do Compose, o workspace alcança todos os outros serviços pelo nome (`gateway:8080`, `postgres:5432`). Isso elimina toda a classe de problemas de endereçamento: de dentro de um devcontainer independente, `localhost` não é o `localhost` onde o Compose publicou suas portas.

```jsonc
{
  "name": "<project> (workspace)",
  "dockerComposeFile": ["../compose.yaml", "../compose.override.yaml"],
  "service": "workspace",
  // Naming a profiled service explicitly on `up` enables it without --profile;
  // its depends_on brings the infrastructure up with it.
  "runServices": ["workspace", "<deps>"],
  "workspaceFolder": "/workspace",
  "remoteUser": "dev",
  "shutdownAction": "none"
}
```

`shutdownAction: none`: fechar o editor não derruba a stack.

## 2. As duas mecânicas de montagem

Toda a história de herança de identidade se reduz a escolher entre duas:

- **A: bind mount direto somente leitura.** Para tudo o que o processo apenas *lê*.
- **B: semente → cópia no boot.** Para tudo o que o processo *reescreve*. O arquivo do host é montado somente leitura em um caminho de staging; o entrypoint o copia uma vez para o caminho real, dentro de um volume gravável.

As duas falhas que forçam a mecânica B: nenhuma mensagem aponta para a causa:

| Sintoma | Causa real |
| --- | --- |
| `EBUSY` ao salvar a configuração | A escrita é um **rename atômico** sobre um bind mount de arquivo único. O mount é ele próprio um ponto de montagem, então o rename não consegue substituí-lo. (O Claude Code faz isso em `/model`, `/effort`.) |
| `unable to get credential storage lock` | `git credential approve` (no push) cria um `.lock` **no diretório do arquivo**. Um diretório somente leitura proíbe isso. |

**Regra derivada: se o processo dono do arquivo consegue reescrevê-lo, semeie e copie. Se ele só lê, monte diretamente.**

## 3. Mapa de montagens

| O quê | Host | Mecânica | Destino no container |
| --- | --- | --- | --- |
| Identidade do git | `~/.gitconfig` | ro | `$HOME/.gitconfig` |
| Credenciais do git | `~/.config/git/credentials` | semente → cópia, `chmod 600` | `$HOME/.config/git/credentials` |
| Autenticação do `cursor-agent` | `~/.cursor/cli-config.json` | semente → cópia | `$HOME/.cursor/cli-config.json` |
| Skills | `~/.claude/skills` | ro | `$HOME/.claude/skills` |
| Agentes | `~/.agents` | ro | `$HOME/.agents` |
| Hooks | `~/.claude/hooks-lib` | ro | `$HOME/.claude/hooks-lib` |
| Statusline | `~/.claude/statusline-command.sh`, `~/.claude/statusline-reset-hook.sh`: **cada arquivo, enumerado** | ro | mesmo caminho |
| Configurações do Claude | `~/.claude/settings.json` | semente → cópia | `$HOME/.claude/settings.json` |
| Login do Claude | `~/.claude/.credentials.json` | semente → cópia, `chmod 600` | `$HOME/.claude/.credentials.json` |

Um caminho do host que não existe significa que a montagem é **pulada**, não substituída por um padrão. Teste cada um durante a exploração.

### Detalhes que não são óbvios

- **O Compose não expande globs em um caminho de volume.** Nenhum shell roda sobre ele: `~/.claude/statusline-*.sh` é lido literalmente, não existe no host, e o Docker, prestativo, cria um *diretório* com esse nome. Enumere cada arquivo; e como montar todo o `~/.claude` é um anti-padrão, enumerar é a única saída.
- **`credential.helper = store --file=$HOME/.config/git/credentials`** no gitconfig do host funciona sem mudanças dentro do container, porque `$HOME` é expandido em tempo de execução e resolve para o home do container. É isso que faz a mecânica B cair no destino certo.
- **Uma CLI de tracker remoto (`gh`, `glab`) é opcional e precisa ser uma pergunta.** Um projeto com issues em markdown local não tem um tracker para autenticar: mantenha-a fora da imagem e fora das montagens. Instale-a somente quando o fluxo de trabalho realmente sair do repositório.
- **O Cursor são dois produtos distintos.** O **editor** roda no host e entra no container pela extensão de devcontainer: não há nada para autenticar lá dentro. Só a **CLI `cursor-agent`** precisa de autenticação, e ela mora em `~/.cursor/cli-config.json` (chave `authInfo`), um arquivo que a própria CLI reescreve (modelo, permissões) → mecânica B. **Não** monte todo o `~/.cursor`: `projects/`, `chats/` e `extensions/` são estado indexado pelo caminho do host.
- **Regra geral para CLIs: onde o token mora determina a mecânica.** Arquivo de configuração em texto puro → montagem somente leitura. **Keyring do sistema → variável de ambiente**, porque um keyring não atravessa para dentro de um container. Esta é a armadilha silenciosa: a configuração monta, a CLI mostra o usuário certo, e toda chamada de API continua falhando. Arquivo reescrito pela própria CLI → semente → cópia.
- **A credencial do Claude diverge do host** depois da primeira renovação de token. Elas se tornam duas cópias válidas e independentes da mesma sessão. Se a interna expirar, recriar o volume do home a semeia de novo.
- **Nunca monte todo o `~/.claude`.** Ele guarda estado por caminho de projeto, sessões, histórico e caches: o container sobrescreveria o estado do host, com caminhos que só existem de um dos lados.

## 4. Home persistente

Um volume **nomeado** montado no `$HOME` do container, e não um bind mount.

- Login, sessões e histórico sobrevivem a um `docker compose down`.
- `CLAUDE_CONFIG_DIR` **precisa** apontar para dentro desse volume; caso contrário, o Claude grava no home da imagem (fora do volume) e perde o login a cada recriação. O mesmo raciocínio vale para qualquer outra CLI de agente com um diretório de estado configurável.
- A imagem cria o usuário e faz `chown` do home **antes** de o volume ser montado: um volume nomeado herda dono e permissões do diretório na primeira inicialização.
- **Os caches da toolchain também pertencem a ele.** Os padrões deles já ficam lá (`$HOME/go`, `$HOME/.cache/go-build`, `~/.npm`, `~/.cache/pip`), mas as imagens oficiais os *realocam* para fora do `$HOME`: `golang` define `GOPATH=/go`, `rust` define `CARGO_HOME=/usr/local/cargo`. Deixados ali, vivem na camada do container, e cada recriação rebaixa o conjunto inteiro de dependências. Verifique o que a imagem base define e aponte de volta para dentro do volume do home (ou dê a esse caminho um volume nomeado próprio).

## 5. Identidade do usuário e permissões

- O container roda como `${DOCKER_UID:-1000}:${DOCKER_GID:-1000}`: o UID/GID do host, para que tudo o que for gravado no checkout montado continue com dono do host.
- A imagem cria um usuário real com uid/gid 1000 (`useradd -u 1000 -g 1000 -m -d /home/dev`). Sem isso, o `HOME` cai para `/` (não gravável) e o git e o shell não resolvem.
- `git config --system --add safe.directory <workspace>`: o UID do host raramente é o que construiu a imagem.
- **Verifique primeiro:** se `id -u` no host não for 1000, os padrões precisam ser passados. Nada precisa ser corrigido no checkout quando o dono dele já é o usuário do host.

## 6. Acesso ao socket do Docker (opcional, decida explicitamente)

Necessário somente se o desenvolvedor ou o agente for rodar `docker compose` de **dentro**.

- Monte `/var/run/docker.sock`; os containers sobem como **irmãos**, não como filhos.
- O socket é `root:docker`, então o serviço precisa do GID do grupo `docker` como grupo suplementar (`group_add`), e esse número **varia de máquina para máquina**, então parametrize.
- **Trade-off a declarar em voz alta:** acesso ao socket equivale a root no host. Tudo bem numa máquina pessoal, não tudo bem num runner compartilhado.
- Sem o socket, o workspace ainda alcança todos os serviços pela rede: só não consegue controlá-los.

## 7. O `PATH` precisa sobreviver a um shell de login

`ENV PATH=...` no Dockerfile cobre apenas shells **que não são de login**. O terminal do editor abre `bash -l`, que carrega `/etc/profile`, e no Debian bookworm, a base das imagens oficiais de `golang`, `node` e `rust`, esse arquivo **atribui** `PATH` em vez de acrescentar a ele:

```sh
# /etc/profile: debian bookworm
if [ "`id -u`" -eq 0 ]; then PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"; fi
export PATH
```

Tudo fora desses diretórios desaparece: `/usr/local/go/bin`, `$GOPATH/bin` e `$HOME/.local/bin`, onde o §8 coloca a CLI com autoatualização.

| Sintoma | Causa real |
| --- | --- |
| `go: command not found` no terminal do editor, enquanto o mesmo binário roda bem sob `docker compose exec` | O shell do editor é um shell de login. O `/etc/profile` sobrescreveu o `PATH` que o `ENV` definiu. |

Entregue nos dois modos: `ENV` para o `exec` e o entrypoint, e um drop-in em `profile.d` para o shell de login (o `/etc/profile` carrega `profile.d/*.sh` *depois* da atribuição acima, então o drop-in vence):

```dockerfile
ENV PATH=/home/dev/.local/bin:/usr/local/go/bin:$PATH
RUN printf 'export PATH=/home/dev/.local/bin:/usr/local/go/bin:$PATH\n' \
      > /etc/profile.d/10-workspace-path.sh
```

## 8. CLIs com autoatualização instaladas na imagem

Vale para o Claude Code e para qualquer CLI que o usuário espere que se atualize sozinha:

- `npm install -g` falha nisso de duas formas. Ele cria arquivos de **dono root**, então o uid 1000 não consegue atualizá-los (`claude update` → `no_permissions`) e a CLI fica desatualizada **em silêncio**; e pressupõe o Node, que uma imagem base de Go / Rust / PHP não tem. Acrescentar um runtime inteiro só para hospedar uma CLI é a troca errada.
- Correção: o entrypoint provisiona o build **nativo** no home persistente, uma vez, com `curl -fsSL https://claude.ai/install.sh | bash`, o caminho de instalação recomendado, que funciona em qualquer imagem base e cai em `$HOME/.local/bin`. Os arquivos dentro do volume pertencem ao uid 1000, então a autoatualização continua funcionando. Outras CLIs de agentes trazem o mesmo formato de instalador (`curl -fsSL https://cursor.com/install | bash` para o `cursor-agent`), caindo no mesmo diretório, e o mesmo raciocínio vale para cada uma.
- `claude install latest` é o comando de *atualização* de uma instalação nativa já existente, não uma forma de criar uma. Não o use como primeiro passo.
- Idempotente (não faz nada se o binário já estiver no volume) e de melhor esforço: estar offline no primeiro boot não pode fazer o boot falhar.
- A instalação não serve de nada se `$HOME/.local/bin` não estiver no `PATH` do shell de login: veja §7.

## 9. Responsabilidades do entrypoint

Só isto, depois `exec "$@"`:

1. Copiar cada semente para o destino gravável, **se ainda não estiver lá** (idempotente).
2. Ajustar o modo dos arquivos sensíveis (`600`).
3. Provisionar o build nativo da CLI, se estiver ausente.

```bash
seed() {  # seed_path dest_path [mode]
    [ -f "$1" ] && [ ! -s "$2" ] || return 0
    mkdir -p "$(dirname "$2")"
    cp "$1" "$2" 2>/dev/null || true
    [ -n "$3" ] && chmod "$3" "$2" 2>/dev/null || true
}
```

O comando do serviço é `sleep infinity`: o container existe para ser habitado, não para rodar um processo.

## 10. Exemplo trabalhado: o serviço

Adapte caminhos, imagem base e dependências; o formato é o que importa.

```yaml
  workspace:
    profiles: ['dev-tools']
    build:
      context: .
      target: workspace
    env_file:
      # Always the guarded form. This skill runs *before* the rest of the
      # project, so .env frequently doesn't exist yet, and the bare `- .env`
      # form fails the up with a file-not-found the user has no way to read as
      # "you haven't written this file yet".
      - path: .env
        required: false
      # Same guard, other reason: a token for a CLI whose auth lives in the host
      # keyring and so cannot be mounted.
      - path: ${HOME}/.config/<cli>/token.env
        required: false
    # Match the host user so anything written into the bind-mounted checkout
    # stays host-owned. Override with DOCKER_UID / DOCKER_GID if id -u isn't 1000.
    user: '${DOCKER_UID:-1000}:${DOCKER_GID:-1000}'
    environment:
      HOME: /home/dev
      # Without this, Claude writes its config to the image's home (outside the
      # volume) and loses the login on every recreate.
      CLAUDE_CONFIG_DIR: /home/dev/.claude
    entrypoint: ['bash', '/workspace/docker/entrypoint.workspace.sh']
    command: ['sleep', 'infinity']
    volumes:
      - .:/workspace
      # Persistent writable home: login and sessions survive recreation.
      - workspace_home:/home/dev
      # --- git ---
      - ~/.gitconfig:/home/dev/.gitconfig:ro
      # Staged read-only; the entrypoint copies it to the path the helper
      # expects, so `git credential approve` on push can take its lock.
      - ${HOME}/.config/git/credentials:/home/dev/.git-credentials-seed:ro
      # --- agent config, read-only from the host ---
      - ~/.claude/skills:/home/dev/.claude/skills:ro
      - ~/.agents:/home/dev/.agents:ro
      # Staged, then copied by the entrypoint: a single-file bind mount is a
      # mount point, so the atomic-rename save would EBUSY on it.
      - ~/.claude/settings.json:/home/dev/.claude-seed/settings.json:ro
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  workspace_home:
```

## 11. O Makefile é a porta de entrada do ambiente

O profile que esconde o `workspace` resolve um problema e cria outro. Resolve: `docker compose up` deixa de iniciar um container de ferramentas com as credenciais do host montadas. Cria: agora existem **dois ambientes**, o sistema, e o sistema mais as ferramentas, e a diferença entre eles é uma flag que ninguém memoriza. O Makefile dá um nome a essa diferença: `make up` é o sistema, `make dev` é o ambiente de trabalho.

Sem ele, o custo cai sobre o primeiro dia de quem clona o repositório: `docker compose up -d`, tudo sobe, o devcontainer não, e nada na saída diz por quê.

<!-- markdownlint-disable MD010 -->
```make
COMPOSE := docker compose --profile dev-tools
# The Compose default ${DOCKER_UID:-1000} is right on the machine that wrote the
# setup and silently wrong on a uid-1001 machine, and the symptom (root-owned
# files in the checkout) points nowhere near the cause. Exporting makes the value
# always come from id -u; the Compose default degrades to a safety net for whoever
# calls `docker compose` by hand.
export DOCKER_UID := $(shell id -u)
export DOCKER_GID := $(shell id -g)

# Targets that talk to Docker refuse to run from inside the workspace, and say why.
IN_CONTAINER := $(shell [ -f /.dockerenv ] && echo 1)
define require_host
	@if [ -n "$(IN_CONTAINER)" ]; then \
		echo "This target controls containers and must run on the host."; \
		echo "The workspace has no Docker socket mounted."; \
		exit 1; \
	fi
endef

shell:
	@$(COMPOSE) ps --status running --services | grep -qx workspace \
		|| $(COMPOSE) up -d workspace --wait
	@$(COMPOSE) exec workspace bash -l
```
<!-- markdownlint-enable MD010 -->

Cada peça responde a uma falha cuja mensagem nomeia outra coisa:

- **`--wait` em todo alvo que inicia algo.** `up -d` retorna quando os containers são **criados**, não quando estão utilizáveis. `make dev && make shell` sem ele joga o desenvolvedor no container enquanto o Postgres ainda está inicializando; a primeira migração ou teste falha com `connection refused`, e o erro culpa o código. O `--wait` bloqueia até os healthchecks passarem, o que torna os healthchecks do `compose.yaml` **carga estrutural, não decoração**: um serviço sem healthcheck é considerado pronto no momento em que roda.
- **`--build` no alvo dev.** O `Dockerfile` do workspace muda toda vez que uma ferramenta é adicionada. Sem `--build`, o `up` reaproveita a imagem existente e o desenvolvedor entra num container sem a ferramenta que acabou de adicionar: sem aviso, e a conclusão natural é que o Dockerfile está errado. Com ele, adicionar uma ferramenta é: edite o estágio, rode `make dev`.
- **`--profile` no `down` é obrigatório, não um cuidado extra.** Verificado com `docker compose down --dry-run`: **um `down` sem o profile não remove o container com profile.** Ele derruba a infraestrutura e deixa o `workspace` rodando, agora ligado a uma rede que foi removida e recriada. Duas consequências, ambas com diagnósticos enganosos: um `down`/`up` "limpo" deixa o workspace carregando montagens e ambiente da encarnação anterior (inclusive um `.env` desatualizado); e qualquer teste de recriação feito com um `down` puro é **vazio**: o container nunca morreu, então o `up` seguinte não recria nada. Regra: todo alvo que derruba algo nomeia o profile que subiu as coisas.
- **A guarda de host é o corolário da pergunta 2A.** Responder "não" ao socket produz um ambiente em que metade dos alvos funciona de dentro (`test`, `lint`, `proto`) e a outra metade só de fora (`dev`, `up`, `down`). Sem a guarda, o errado falha com `docker: command not found`, uma mensagem que não menciona socket, profile nem decisão nenhuma, e manda a pessoa instalar Docker dentro do container. Se a 2A foi "sim", a guarda some: os alvos funcionam dos dois lados.
- **`shell` inicia antes de entrar, e entra com um shell de login.** Idempotente, porque "quero um shell" nunca deve virar "primeiro descubra qual comando inicia o container escondido". E `-l`, porque o shell de login é quem carrega `/etc/profile.d`: onde mora a correção de `PATH` do §7. `exec workspace bash` sem `-l` reproduz exatamente o `command not found` que o drop-in existe para evitar.
- **`clean` pergunta, porque o volume guarda credenciais, não apenas dados.** `down -v` num projeto comum apaga dados descartáveis. Aqui ele também apaga o home nomeado: **o login do agente e as sessões dele**. Recuperável (o entrypoint semeia de novo a partir do host), mas o histórico não volta. É o único alvo destrutivo e o único que pede confirmação; a confirmação existe porque `clean` soa inofensivo e, neste padrão, não é.

**O que varia por stack.** Os alvos de ciclo de vida (`dev`, `up`, `down`, `shell`, `ps`, `logs`, `clean`) são o padrão e valem em qualquer projeto. Os alvos de código (`test`, `lint`, `proto`, `e2e`) pertencem ao projeto e **não devem ser criados por esta skill enquanto não houver código**: um `make test` que falha porque nenhum módulo existe ensina desconfiança do Makefile já no primeiro uso.

## 12. Anti-padrões

O que esta skill existe para evitar:

- Imagem de devcontainer independente + socket montado → traz de volta o problema de rede.
- Montar o `settings.json` somente leitura no caminho final → `EBUSY` no primeiro `/model`.
- Montar o diretório de credenciais do git somente leitura → o push quebra no lock.
- Montar todo o `~/.claude` → colisão de estado com o host.
- Rodar como root → arquivos de dono root no checkout, e `sudo` para editá-los depois.
- Gravar um segredo na imagem → tudo entra por montagem em tempo de execução.
- Home em um bind mount dentro do checkout → o estado do container polui o repositório.
- `PATH` definido só por `ENV` → funciona sob `exec`, quebrado no terminal do editor.
- O cache da toolchain deixado onde a imagem base o colocou (`/go`, `/usr/local/cargo`) → cada recriação baixa tudo de novo.
- `docker compose down` sem `--profile` → o workspace sobrevive, e qualquer teste de recriação construído em cima disso não prova nada.
- Deixar a flag do profile como conhecimento tribal em vez de nomeá-la em um alvo do Makefile → `docker compose up` inicia tudo menos o devcontainer, em silêncio.
- Escrever alvos `test` / `lint` / `proto` antes de existir o código que eles rodam → o primeiro uso do Makefile é uma falha.
- Trazer testcontainers quando os testes já rodam dentro da rede do Compose.
- Fixar uma tag de imagem que você nunca verificou que existe → a falha aparece no `up`, depois que todo o resto já foi escrito.
