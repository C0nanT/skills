```yaml
name: setup-devcontainer
description: Configure um devcontainer baseado em Compose que herda a identidade de git, CLI e agente do host, com a toolchain dentro do container, o host limpo e nada para autenticar de novo. Invocado pelo usuário.
disable-model-invocation: true
```

# Configurar devcontainer

Dê a este repositório um container de desenvolvimento que atenda a dois desejos que normalmente brigam:

1. **Host limpo**: nenhuma toolchain instalada na máquina (compilador, runtime, geradores, clientes de banco de dados, linters).
2. **Zero novo login**: git, as CLIs dos agentes e qualquer CLI de tracker funcionam *dentro* do container com a identidade que já existe no host.

O caminho ingênuo: uma imagem de devcontainer independente com um `postCreateCommand` que instala tudo. Ele falha nos dois desejos: autentica de novo a cada recriação e não alcança os serviços do projeto.

**A decisão estruturante: o devcontainer é um serviço da stack Compose do projeto**, não uma imagem independente. Ele se chama `workspace`, fica atrás de um profile para que um `docker compose up` normal não o inicie, e o `.devcontainer/devcontainer.json` aponta para os arquivos Compose e o nomeia. Estar na rede do Compose é o que permite alcançar `postgres:5432` e `gateway:8080` pelo nome; de dentro de um devcontainer independente, `localhost` não é o `localhost` onde o Compose publicou as portas, e descobrir isso custa uma tarde.

Leia [REFERENCE.pt-BR.md](./REFERENCE.pt-BR.md) antes de rascunhar qualquer coisa. Ele traz as duas mecânicas de montagem, a tabela de falhas que as tornam necessárias, o mapa completo de montagens e os anti-padrões. Este arquivo é o processo; aquele é o raciocínio de que você precisa para adaptá-lo.

Rode isto **antes** do restante do projeto. Configurado depois, a toolchain já terá sido instalada no host "só desta vez".

## Processo

### 1. Explore

Leia o repositório e o host antes de perguntar qualquer coisa. Toda pergunta que você consegue responder olhando é uma pergunta que você não faz.

**No repositório:**

- Já existe um arquivo Compose (`compose.yaml`, `docker-compose.yml`) e um override? → acrescente o serviço `workspace` ao override. Se não → crie o par.
- Existe um `Dockerfile`? Ele tem estágios ao lado dos quais você pode adicionar um estágio `workspace`, reusando a mesma imagem base?
- **Projeto do zero: nenhum serviço de aplicação existe ainda.** Isso é esperado, já que isto roda primeiro. A stack que você cria é só de infraestrutura: `workspace` mais o que ele acessa (banco de dados, cache, tracing). Os serviços de aplicação entram à medida que ganham um entrypoint; não invente placeholders para eles. No Dockerfile, o mesmo vale: escreva um estágio `base` sobre o qual `workspace` é construído, para que os estágios do app tenham de onde herdar depois.
- Linguagem e toolchain: `go.mod`, `composer.json`, `package.json`, `pyproject.toml`, `Cargo.toml`, `*.csproj`, `Gemfile`. Leia-os também pela *versão*, não só pela linguagem.
- Convenção de diretório de trabalho: um `WORKDIR` existente no Dockerfile, ou o do próprio framework (`/var/www/html`, `/app`, `/workspace`).
- Ferramental extra que o projeto de fato invoca: geradores de código (`protoc`, `sqlc`, `buf`), ferramentas de migração, clientes de banco de dados, linters. Procure no Makefile / task runner / scripts, não no que a linguagem "costuma" precisar.
- Existe Makefile ou task runner? → os alvos de ciclo de vida vão **para dentro dele**; um segundo ponto de entrada é pior do que nenhum. Se não existir, você criará um (REFERENCE.pt-BR.md §11): o profile que esconde `workspace` é inutilizável sem um comando nomeado.
- **Clientes de banco de dados: use o major da versão do serviço em execução, não o que a distribuição traz.** O pacote da distro fica para trás: o `postgresql-client` do bookworm é o 15, e o `pg_dump` recusa um servidor 17 de imediato. Leia a versão do serviço Compose e adicione o repositório do fabricante (PGDG e equivalentes) quando a distro não o alcançar.
- `.devcontainer/` existente: se houver um, isto é uma migração, não uma configuração do zero. Diga isso e mostre o diff antes de substituí-lo.
- Como os testes do projeto alcançam a infraestrutura. Se eles já rodam dentro da rede do Compose, **não** traga testcontainers.

**No host:**

| O quê | Como |
| --- | --- |
| UID / GID | `id -u`, `id -g`: se não for 1000, os padrões precisam ser passados |
| Grupo do socket do Docker | `getent group docker`: o GID varia de máquina para máquina, então parametrize |
| Quais configurações do host existem | Teste cada caminho do mapa de montagens do REFERENCE.pt-BR.md; um caminho ausente significa que a montagem é pulada, não substituída por um padrão |
| Onde uma CLI guarda o token | Arquivo de configuração simples → monte-o. Keyring do sistema → não atravessa para o container; carrega só por variável de ambiente |
| …sem ler o segredo | `test -f`, `ls -l`, `grep -l oauth_token`: você precisa da *localização e do formato*, nunca do valor. `cat` num arquivo de credencial pode ser negado pela camada de permissões, e essa negação não deve travar a configuração: recorra à existência e ao tamanho do arquivo, ou pergunte |

Pronto quando você conseguir nomear a imagem base, o diretório de trabalho, cada caminho do host que existe e cada serviço do qual o workspace precisa depender.

### 2. Pergunte só o que se ramifica

Apresente primeiro o que encontrou e depois pergunte. Comece pela resposta recomendada, para que o usuário possa aceitá-la em uma palavra. Tudo o que a exploração resolveu é afirmado, não perguntado.

**A: Acesso ao socket do Docker.** É a única pergunta com uma troca de segurança, então faça-a explicitamente, nunca presuma.

> O workspace deve conseguir rodar `docker compose` lá de dentro? (recomendado: **não**, a menos que você saiba que precisa)

> Montar `/var/run/docker.sock` faz os containers iniciados lá de dentro serem **irmãos**, não filhos, e equivale a root no host: tudo bem numa máquina pessoal, não tudo bem num runner compartilhado. Sem ele, o workspace ainda alcança todos os serviços pela rede; só não consegue controlá-los.

**B: CLI de tracker remoto.** Pergunte; nunca instale por reflexo.

> O fluxo de trabalho sai do repositório: issues ou MRs no GitHub / GitLab? (recomendado: **não**, quando as issues são markdown local)

> Um projeto que acompanha o trabalho em arquivos markdown não tem nada para autenticar: `gh` / `glab` ficam fora da imagem e fora das montagens. Se sim, descubra onde essa CLI guarda o token antes de prometer que vai funcionar: um token guardado em keyring precisa de uma variável de ambiente, e o modo de falha silenciosa é a CLI mostrar o nome de usuário certo enquanto toda chamada de API falha.

**C: Ferramentas extras na imagem.** Confirme a lista que a exploração produziu e pergunte o que ela deixou de fora. Isto é uma checklist para aceitar, não uma pergunta aberta.

**D: CLIs de agentes a levar para dentro.** Confirme quais das encontradas no host devem ser conectadas (Claude Code, `cursor-agent`, outras). Cada uma custa apenas suas montagens; uma CLI que o usuário não usa é ruído na configuração. Pergunte: uma lista presumida aqui e apenas *anunciada* no rascunho é a pergunta mais fácil de pular nesta skill, e suas montagens e seu instalador são as partes mais difíceis de desfazer depois.

Qualquer coisa que a exploração deixou genuinamente ambígua (duas imagens base plausíveis, um diretório de trabalho pouco claro) também é perguntada aqui, com a sua recomendação primeiro.

### 3. Rascunhe e confirme

Mostre o conjunto completo de arquivos antes de escrever qualquer um deles:

- O serviço `workspace` a acrescentar ao override do Compose (ou o novo override).
- O estágio de imagem `workspace`.
- `.devcontainer/devcontainer.json`.
- O script de entrypoint.
- Os alvos de ciclo de vida do Makefile (`dev`, `up`, `down`, `shell`, `ps`, `logs`, `clean`): acrescentados ao Makefile existente, ou um novo.

**Verifique cada tag de imagem fixada antes que ela entre no rascunho**: `docker manifest inspect <image>:<tag>` ou a lista de tags do registro. Uma tag com cara de tag não é uma tag: `jaegertracing/all-in-one:1.62` não existe, só `1.62.0` existe, e sem verificação ela falha no `up`, depois que a stack inteira já foi escrita, e a falha parece um problema do Compose.

Deixe o usuário editar o rascunho. Nomeie explicitamente, em uma linha cada: quais caminhos do host estão sendo montados, se o socket está incluído e quais serviços os `depends_on` vão trazer junto.

### 4. Escreva

Siga esta ordem: cada passo depende do anterior:

1. Serviço `workspace` no override + estágio de imagem com um usuário real de uid 1000 e a toolchain: `PATH` escrito tanto como `ENV` quanto como um drop-in em `/etc/profile.d`.
2. `.devcontainer/devcontainer.json` apontando para os arquivos Compose.
3. Volume nomeado para o home + `CLAUDE_CONFIG_DIR` (e qualquer equivalente para outras CLIs de agentes).
4. Montagens diretas somente leitura.
5. Entrypoint + sementes graváveis.
6. Socket do Docker, somente se a resposta 2A foi sim.
7. Alvos de ciclo de vida no Makefile: todo start com `--wait`, o alvo dev com `--build`, todo desligamento nomeando o profile, e a guarda `/.dockerenv` do host nos alvos voltados ao Docker, a menos que 2A tenha dito sim. Só ciclo de vida: nenhum alvo `test` / `lint` / `proto` enquanto não houver código para ele rodar.

Toda construção aqui: por que o volume do home precisa ser nomeado, por que o `useradd` roda na imagem, por que alguns arquivos são semeados em vez de montados, está no REFERENCE.pt-BR.md. Não improvise uma variante de nenhuma delas sem ler a justificativa; cada uma existe porque a alternativa óbvia falha de um jeito cuja mensagem de erro não nomeia a causa.

### 5. Verifique

Construa, inicie e rode o script de aceitação de *dentro* do container. Relate a saída real: um passo que você não conseguiu rodar é reportado como não executado.

Todo passo precisa ser executável de forma não interativa: uma checagem que exige um TUI é uma checagem que nunca roda.

```sh
id                              # host uid/gid
git config user.email           # host email
git ls-remote                   # credentials work (read)
ls ~/.claude/skills             # skills visible
cp F F.tmp && mv F.tmp F        # for each seeded file F: the atomic rename itself
findmnt -T F                    # …and F is not a mount point → no EBUSY
bash -lc 'go version'           # login shell, not exec: catches the /etc/profile PATH reset
touch <file> in the repo        # on the host, owner is your user
curl <service>:<port>           # Compose network reachable
docker compose ps               # only if the socket was mounted
```

Dois deles precisam de um plano B:

- **`git ls-remote` pressupõe um remoto.** Um repositório do zero não tem nenhum. Então prove o helper: `git credential fill` alimentado com o host e o protocolo, canalizado direto para `grep '^username='`. Nunca imprima a saída bruta dele, ela contém a linha da senha.
- **O teste de renomeação substitui "abra a CLI e rode `/model`".** Ele exercita a mesma mecânica (a renomeação atômica que dá `EBUSY` sobre um bind mount de arquivo único) sem um humano diante de um TUI.

Depois, o teste de verdade: aquele que prova a camada de persistência, e o mais provável de ser pulado:

```bash
docker compose ps -q workspace                                   # note the container ID
docker compose --profile dev-tools down                          # the profile is not optional
docker compose --profile dev-tools up -d workspace --wait
docker compose ps -q workspace                                   # must be a *different* ID
```

**Sem `--profile`, o `down` deixa o container com profile rodando**: o `up` seguinte não recria nada e o teste não prova nada, enquanto parece passar. O ID do container que muda é a evidência de que ele de fato morreu; se o ID for o mesmo, você não testou nada. Rode isso pelos alvos do Makefile assim que existirem; é para isso que os alvos servem.

Login e sessões do agente precisam continuar lá depois. Se não estiverem, o volume do home não é nomeado, não está montado no `$HOME` do container, ou a CLI está configurada para gravar fora dele.

### 6. Pronto

Diga ao usuário:

- Quais arquivos você criou ou alterou, e quais caminhos do host agora estão montados no container.
- Os dois comandos que viram o ponto de entrada: `make dev` para o ambiente de trabalho, `make up` para só o sistema, e que `make shell` é como se entra.
- Se o socket do Docker está montado e, se estiver, repita o trade-off uma vez para que a decisão fique registrada.
- Quais checagens de aceitação passaram, e quais falharam ou você não conseguiu rodar.
- Que a toolchain agora pertence ao container: novas ferramentas vão para o estágio da imagem, não para o host.
