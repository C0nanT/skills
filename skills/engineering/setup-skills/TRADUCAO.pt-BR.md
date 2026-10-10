```yaml
name: setup-skills
description: Configure este repositório para as skills de engenharia: configure o issue tracker, o vocabulário de rótulos de triagem, a organização dos documentos de domínio e as permissões do Claude Code do projeto que negam git destrutivo. Rode uma vez antes do primeiro uso das outras skills de engenharia.
disable-model-invocation: true
```

# Configurar skills

Monte a configuração por repositório que as skills de engenharia pressupõem:

- **Issue tracker**: onde as issues ficam (markdown local por padrão; GitHub / GitLab / outro, quando você escolher aqui)
- **Rótulos de triagem**: as strings usadas para os seis papéis canônicos de triagem
- **Documentos de domínio**: onde ficam o `GLOSSARY.md` e os ADRs, e as regras de consumo para lê-los
- **Guardrails de git**: entradas `permissions.deny` no `.claude/settings.json` deste repositório que bloqueiam git destrutivo (`push`, `reset`, …). **Não** instale nem registre hooks: o usuário já tem hooks globais, se quiser.

Esta é uma skill guiada por prompt, não um script determinístico. Explore, apresente o que encontrou, confirme com o usuário e só então escreva.

## Processo

### 1. Explore

Olhe o repositório atual para entender o ponto de partida. Leia o que existe; não presuma:

- `git remote -v` e `.git/config`: é um repositório do GitHub? Qual?
- `AGENTS.md` e `CLAUDE.md` na raiz do repositório: algum deles existe? Já há uma seção `## Agent skills` em algum?
- `GLOSSARY.md` e `GLOSSARY-MAP.md` na raiz do repositório
- `docs/adr/` e qualquer diretório `src/*/docs/adr/`
- `docs/agents/`: a saída anterior desta skill já existe?
- `.scratch/`: sinal de que uma convenção de issue tracker em markdown local já está em uso
- `.claude/settings.json`: o `permissions.deny` já lista as regras `Bash(git …)` de git destrutivo?
- Sinais de monorepo: um `pnpm-workspace.yaml`, um campo `workspaces` no `package.json`, ou um `packages/*` populado com `src/` próprio. Só aparece em um repositório realmente grande, com vários pacotes; a ausência disso significa contexto único, que é quase todo repositório.

### 2. Apresente o que encontrou e pergunte

Resuma o que está presente e o que falta. Depois, siga as seções em ordem. Uma seção, uma resposta, depois a próxima.

Abra cada seção com a resposta recomendada, para que o usuário possa aceitá-la em uma palavra. Dê uma explicação de uma linha apenas quando a escolha realmente se ramificar; pule a seção por completo quando a exploração já a tiver resolvido (a Seção C quando não há monorepo, a Seção D quando a lista de negações do projeto já existe).

**Seção A: Issue tracker.**

> Explicação: O "issue tracker" é onde as issues deste repositório ficam. Skills como `to-tickets` e `to-spec` leem este arquivo e publicam ali sem perguntar a cada execução, então escolha o lugar onde você realmente acompanha o trabalho. Se você pular a configuração (ou ainda não a tiver rodado), essas skills caem para **markdown local** por conta própria. O usuário ainda pode mudar o destino de uma única execução pedindo explicitamente.

Postura padrão: prefira o **markdown local**, a menos que o usuário claramente queira um tracker remoto. Se um `git remote` aponta para o GitHub e o usuário quer issues remotas, proponha o GitHub. Se um `git remote` aponta para o GitLab (`gitlab.com` ou um host self-hosted) e ele quer issues remotas, proponha o GitLab. Caso contrário, ofereça:

- **Markdown local** (padrão recomendado): as issues vivem como arquivos em `.scratch/<feature>/` neste repositório (bom para projetos solo ou quando você não quer criar issues remotas)
- **GitHub**: as issues vivem nas GitHub Issues do repositório (usa a CLI `gh`)
- **GitLab**: as issues vivem nas GitLab Issues do repositório (usa a CLI [`glab`](https://gitlab.com/gitlab-org/cli))
- **Outro** (Jira, Linear etc.): peça ao usuário para descrever o fluxo em um parágrafo; a skill registra isso como prosa livre

Registre a escolha em `docs/agents/issue-tracker.md`. Os modelos do GitHub e do GitLab trazem a flag "PRs como superfície de pedidos", com padrão **desligada**. Deixe-a desligada e não a levante: um usuário que queira PRs externos na fila de triagem pode mudar a flag no arquivo depois.

> Explicação: Repositórios de código aberto costumam receber pedidos de funcionalidade como pull requests, não só como issues; um PR é uma issue com código anexado. Se você ligar esta opção, PRs externos entram na mesma fila de triagem e passam pelos mesmos rótulos e estados das issues (os PRs em andamento de colaboradores são deixados em paz). Deixe-a desligada se PRs não forem uma superfície de pedidos para você.

**Seção B: Rótulos de triagem.** Sempre roda, esteja ou não instalada uma skill de triagem: os rótulos também são como `to-spec`, `to-tickets` e `review-axes` registram o estado. Faça exatamente uma pergunta:

> Você quer manter os rótulos de triagem padrão? (recomendado: **sim**)

> Explicação: Quando uma issue recebida é triada, ela passa por uma máquina de estados: precisa de avaliação, aguarda o autor, está pronta para um agente AFK pegar, está pronta para um humano, ou não será corrigida. Para isso, as skills de engenharia aplicam rótulos (ou o equivalente no seu issue tracker) que correspondem a strings *que você de fato configurou*. Se o seu repositório já usa outros nomes de rótulo (por exemplo, `bug:triage` em vez de `needs-triage`), mapeie-os aqui para que os certos sejam aplicados em vez de criar duplicatas.

**Seção C: Documentos de domínio.** Use por padrão o **contexto único** (um `GLOSSARY.md` + `docs/adr/` na raiz do repositório). Isso serve para quase todo repositório; escreva sem perguntar.

Ofereça o **multi-contexto** (um `GLOSSARY-MAP.md` na raiz apontando para arquivos `GLOSSARY.md` por contexto) só quando a exploração encontrar sinais de monorepo. Aí, confirme qual layout o usuário quer.

**Seção D: Guardrails de git.** Recomendado: **sim**. Pule quando o `.claude/settings.json` já contiver as regras de negação da lista-semente abaixo (todas, ou um superconjunto claro que o usuário personalizou).

> Adicionar regras `permissions.deny` do projeto que bloqueiam git destrutivo no Claude Code? (recomendado: **sim**)

> Explicação: Mescla regras de negação apenas no `.claude/settings.json` **deste repositório**, sem hooks e sem scripts. O Claude Code recusa `git push`, `git reset`, `git clean`, `git rebase` (também na forma `git -C <dir> …`), deleção forçada de branches, checkouts e restores que descartam tudo, `stash drop`/`clear` e deleção forçada de tags. O git somente leitura continua funcionando. Suas configurações existentes (regras de permissão, hooks, env) são mantidas, um backup com carimbo de data e hora é gravado antes de o arquivo ser substituído, e a mesclagem para sem tocar em nada se o `jq` estiver ausente ou se o arquivo não for um JSON válido. Seus hooks globais existentes continuam intactos. Diga **não** apenas se quiser que o agente possa alterar o histórico do git neste repositório.

Se o usuário disser **não**, omita a mesclagem de negações, o `docs/agents/git-guardrails.md` e o sub-bloco `### Git guardrails`. Não remova regras de negação existentes quando ele disser não.

### 3. Confirme e edite

Mostre ao usuário um rascunho de:

- O bloco `## Agent skills` a acrescentar no arquivo que está sendo editado, `CLAUDE.md` ou `AGENTS.md` (veja o passo 4 para as regras de escolha)
- O conteúdo de `docs/agents/issue-tracker.md`, `docs/agents/domain.md` e `docs/agents/triage-labels.md`
- Quando a Seção D for sim: `docs/agents/git-guardrails.md` e as entradas `permissions.deny` que serão mescladas no `.claude/settings.json`

Deixe-o editar antes de gravar.

### 4. Escreva

**Escolha o arquivo a editar:**

- Se `CLAUDE.md` existir, edite-o.
- Senão, se `AGENTS.md` existir, edite-o.
- Se nenhum existir, pergunte ao usuário qual criar; não escolha por ele.

Nunca crie `AGENTS.md` quando `CLAUDE.md` já existir (ou o contrário); sempre edite o que já está lá.

Se já existir um bloco `## Agent skills` no arquivo escolhido, atualize o conteúdo dele no lugar, em vez de acrescentar uma duplicata. Não sobrescreva edições do usuário nas seções ao redor.

O bloco:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### Git guardrails

Destructive git (`push`, `reset`, …) is denied via `permissions.deny` in `.claude/settings.json`. See `docs/agents/git-guardrails.md`.
```

Inclua o sub-bloco `### Git guardrails` e escreva `docs/agents/git-guardrails.md` somente quando a Seção D tiver sido **sim**. Quando a Seção D tiver sido **não**, omita-os.

No GitHub ou no GitLab, crie cada rótulo configurado que o tracker não tiver (`gh label create` / `glab label create`).

Depois, escreva os arquivos de documentação usando os modelos-semente desta pasta de skill como ponto de partida:

- [issue-tracker-github.pt-BR.md](./issue-tracker-github.pt-BR.md): issue tracker do GitHub
- [issue-tracker-gitlab.pt-BR.md](./issue-tracker-gitlab.pt-BR.md): issue tracker do GitLab
- [issue-tracker-local.pt-BR.md](./issue-tracker-local.pt-BR.md): issue tracker em markdown local
- [triage-labels.pt-BR.md](./triage-labels.pt-BR.md): mapeamento de rótulos
- [domain.pt-BR.md](./domain.pt-BR.md): regras de consumo dos documentos de domínio e layout
- [git-guardrails.pt-BR.md](./git-guardrails.pt-BR.md): documenta a lista de negações do projeto (somente se a Seção D for sim)

Para trackers de issues "outros", escreva `docs/agents/issue-tracker.md` do zero, usando a descrição do usuário.

#### 4a. Regras de negação de git do projeto (somente Seção D = sim)

Escreva **apenas** no `.claude/settings.json` do projeto-alvo. **Não** crie `.claude/hooks/`, **não** registre `PreToolUse`, **não** copie scripts, **não** toque em `~/.claude/settings.json`.

Requer `jq`. Rode a mesclagem abaixo como uma única chamada de Bash. Ela só acrescenta as regras que faltam, mantém todo o resto do arquivo (regras de permissão, hooks, env, entradas de negação já existentes e a ordem delas) e grava um backup com carimbo de data e hora ao lado do arquivo antes de substituí-lo. Cria `{}` somente quando o arquivo está ausente ou vazio.

Se o trecho sair com código diferente de zero (sem `jq`, ou o arquivo não é um objeto JSON), repasse a mensagem ao usuário e interrompa a Seção D ali: **não** recrie o arquivo, não semeie `{}` e não edite a lista de negações à mão como contorno. O usuário corrige a causa e roda de novo.

Lista-semente de negações (mescle estas strings em `permissions.deny`; mantenha as entradas existentes que o projeto já tenha). Cada regra `git -C` vem em duas formas, porque um espaço seguido de `*` no fim só casa com o comando nu quando ele é o único curinga da regra: `Bash(git -C * push *)` sozinho deixaria passar `git -C . push`.

```text
Bash(git push *)
Bash(git reset *)
Bash(git clean *)
Bash(git rebase *)
Bash(git -C * push)
Bash(git -C * push *)
Bash(git -C * reset)
Bash(git -C * reset *)
Bash(git -C * clean)
Bash(git -C * clean *)
Bash(git -C * rebase)
Bash(git -C * rebase *)
Bash(git branch -D *)
Bash(git branch --delete --force *)
Bash(git checkout . *)
Bash(git restore . *)
Bash(git stash drop *)
Bash(git stash clear *)
Bash(git tag -d *)
Bash(git tag -D *)
```

Mesclagem idempotente:

```bash
# setup-skills: merge git deny rules
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
SETTINGS="$PROJECT_ROOT/.claude/settings.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "setup-skills: jq is required to merge deny rules. Install jq and re-run. $SETTINGS was not touched." >&2
  exit 1
fi

mkdir -p "$(dirname "$SETTINGS")"
if [ ! -e "$SETTINGS" ] || [ -z "$(tr -d '[:space:]' < "$SETTINGS")" ]; then
  echo '{}' > "$SETTINGS"
elif ! jq -e 'type == "object"' "$SETTINGS" >/dev/null; then
  echo "setup-skills: $SETTINGS is not a valid JSON object (see the jq error above, if any). Fix it and re-run. The file was not touched." >&2
  exit 1
fi

TMP="$(mktemp "$SETTINGS.XXXXXX")"
if ! jq --indent 2 '
  .permissions //= {}
  | .permissions.deny //= []
  | reduce (
      [
        "Bash(git push *)",
        "Bash(git reset *)",
        "Bash(git clean *)",
        "Bash(git rebase *)",
        "Bash(git -C * push)",
        "Bash(git -C * push *)",
        "Bash(git -C * reset)",
        "Bash(git -C * reset *)",
        "Bash(git -C * clean)",
        "Bash(git -C * clean *)",
        "Bash(git -C * rebase)",
        "Bash(git -C * rebase *)",
        "Bash(git branch -D *)",
        "Bash(git branch --delete --force *)",
        "Bash(git checkout . *)",
        "Bash(git restore . *)",
        "Bash(git stash drop *)",
        "Bash(git stash clear *)",
        "Bash(git tag -d *)",
        "Bash(git tag -D *)"
      ][]
    ) as $rule (.; if (.permissions.deny | index([$rule])) then . else .permissions.deny += [$rule] end)
' "$SETTINGS" > "$TMP"; then
  rm -f "$TMP"
  echo "setup-skills: jq could not merge into $SETTINGS. The file was not touched." >&2
  exit 1
fi

if cmp -s "$TMP" "$SETTINGS"; then
  rm -f "$TMP"
  echo "setup-skills: deny rules already present, $SETTINGS unchanged."
else
  BACKUP="$SETTINGS.bak-$(date +%Y%m%d%H%M%S)"
  cp -p "$SETTINGS" "$BACKUP"
  mv "$TMP" "$SETTINGS"
  echo "setup-skills: merged deny rules into $SETTINGS (backup: $BACKUP)."
fi
```

Escreva também `docs/agents/git-guardrails.md` a partir do modelo-semente.

### 5. Pronto

Diga ao usuário que a configuração está completa e quais skills de engenharia passarão a ler estes arquivos. Se os guardrails de git foram adicionados, aponte para `.claude/settings.json` → `permissions.deny` (não para hooks). Mencione que ele pode editar `docs/agents/*.md` e a lista de negações diretamente depois: rodar esta skill de novo só é necessário se ele quiser trocar de issue tracker, atualizar as regras de negação ou recomeçar do zero.

Depois, recomende, sem executar: a skill complementar `/setup-solid` escreve uma seção SOLID no `CLAUDE.md`, no nível de arquitetura, independente de linguagem e delimitada pela regra do escoteiro, de modo que SOLID se aplique ao código novo e ao código que cada mudança já toca, em vez de disparar uma refatoração do repositório inteiro. É o padrão de código para o qual os fluxos de engenharia depois constroem. Deixe para o usuário digitar.
