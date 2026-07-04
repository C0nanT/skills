# Resumo: divergência entre seu fork e o upstream (mattpocock/skills)

Ponto de partida comum (`merge-base`): `5d78bd0` ("fix: correct spelling of 'domain-modeling'...").
Desde então:
- **upstream/main** avançou **88 commits**
- **seu main** avançou **47 commits**

Ou seja, os dois lados mudaram bastante — não é um simples "puxar novidades", é uma reconciliação real de duas linhas de desenvolvimento independentes.

---

## 1. O que o upstream (Matt Pocock) fez

### Skills novas
- **`wayfinder`** (era `decision-mapping`, renomeado) — reescrito quase por completo: virou um sistema de planejamento colaborativo via issue tracker (mapa = índice, não armazenamento), com templates de mapa/ticket, regra de bloqueio nativo, terminologia "claim por assign", etc. É a área com mais commits (~20).
- **`research`** — nova skill de pesquisa.
- **`triage`** — nova skill (mapeia com o `docs/engineering/triage.md` que você já tem aberto no IDE).
- **`codebase-design`** e **`domain-modeling`** — novas skills de arquitetura/modelagem, com docs de apoio (`DEEPENING.md`, `DESIGN-IT-TWICE.md`, `ADR-FORMAT.md`, `CONTEXT-FORMAT.md`).
- **`teach`** — nova skill, com vários formatos de apoio (glossário, registro de aprendizado, missão, recursos).
- **`git-guardrails-claude-code`**, **`migrate-to-shoehorn`**, **`scaffold-exercises`** — novas skills em `misc/`.
- **`wizard`** e **`claude-handoff`** — novas skills em `in-progress/`.
- **`obsidian-vault`**, **`edit-article`** — novas skills em `personal/`.

### Renomeações / promoções
- **`review` → `code-review`**, promovida para `engineering/` (deixou de ser "in-progress").
- **`decision-mapping` → `wayfinder`** (ver acima).

### Skills reformuladas
- **`tdd`** — mudança de fio: removeu a etapa de "refactor" (agora é red → green, não red → green → refactor), virou "reference-only" com seams pré-acordados, adicionou anti-padrão de "teste tautológico". Isso é uma mudança de filosofia, não só de texto — vale sua atenção especial já que você tem esse arquivo aberto no editor agora.
- **`grilling`** — adicionou gate de confirmação e "leading word".
- **`ask-matt`** — vira o "roteador" que mapeia todas as skills e como se relacionam (no seu fork isso é o `ask-skills`, renomeado e com guia em PT-BR — ver conflito abaixo).

### Infraestrutura / processo
- Adotou **changesets** (`.changeset/*.md`, `CHANGELOG.md`) para gerenciar releases — antes não existia isso.
- Novo workflow `.github/workflows/release.yml` (publicação automatizada), removeu `validate.yml`.
- Reestruturou `docs/`: moveu para `.agents/`, criou página de docs individual para cada skill promovida (`docs/engineering/<skill>.md`), com convenção documentada em `.agents/writing-docs.md`.
- **Removeu `.claude-plugin/marketplace.json`** por completo (48 linhas).
- Reescreveu `CLAUDE.md` e `README.md` de forma significativa (90 e 157 linhas alteradas respectivamente) — nova convenção de "buckets promovidos vs não-promovidos", docs pages, etc.

### Coisa importante: skills que o upstream **nunca teve**
`caveman`, `setup-statusline`, `reset-agent-env` e `marketplace.json` **não existem no upstream** — são adições exclusivamente suas, criadas depois do ponto de divergência. Isso não é conflito de "quem apagou o quê"; é só que upstream nunca teve esses arquivos, então o merge vai mantê-los tranquilamente (sem risco de perda).

---

## 2. O que você fez no seu fork

- **Renomeou `ask-matt` → `ask-skills`** em toda a documentação e skills, criou guia em PT-BR (`docs/guides/pt-br/ask-skills.md`). **Isso conflita diretamente com o que o upstream fez no mesmo arquivo** (upstream expandiu `ask-matt` significativamente enquanto você o renomeava) — é o conflito mais delicado do merge.
- Adicionou a skill **`reset-agent-env`** (limpa configs globais de agentes) — exclusiva do fork.
- Adicionou/evoluiu **`setup-statusline`** (com reset e métricas) — exclusiva do fork, passou por várias iterações (`5f0856f`, `5fdbcf3`, `bb5dd50`, `aa5c518`).
- Criou e iterou bastante em **`.claude-plugin/marketplace.json`** (várias tentativas: `e4a3234`, `a8edb21`, `571f4b4`, `9a36440`, `6edbe57`, `fc4625b`, `6bea0ef`, `7e29c99`) — parece ter sido um processo de tentativa e erro (inclusive um commit literalmente chamado `3dde472 teste`) até chegar num agrupamento por pastas. **Esse arquivo não existe mais no upstream**, então o merge não vai conflitar tecnicamente, mas vale decidir se você ainda quer mantê-lo.
- Adicionou scripts e docs de **`claude-hooks`** (`af843fb`, `3d71129`, `f709976`, `0117105`) e ajustou o README pra explicar a relação entre claude-hooks e skills instaladas.
- Endureceu o **`git-guardrails`** pra bloquear também `git commit` (`212af21`) — nota: o upstream também tem uma skill de guardrails nova (`git-guardrails-claude-code`) com outro escopo/script; vale comparar as duas depois do merge pra não duplicar proteção.
- Ajustes de `README.md`/`CLAUDE.md` pra deixar claro que é um fork (`ec76d65`, `b931c5c`, e vários outros "Update README...").
- Trocou `.markdownlint.json` por `.markdownlint.jsonc` e ajustou `validate.sh` (commit mais recente, `f38ce49`).

---

## 3. Conflitos reais no merge (6 arquivos)

| Arquivo | Motivo do conflito |
|---|---|
| `.claude-plugin/plugin.json` | Lista de skills divergiu — upstream adicionou várias novas, fork adicionou `caveman` |
| `CLAUDE.md` | Ambos os lados reescreveram a seção de "Invariantes" e "Skill Structure" de formas diferentes |
| `README.md` | Reescrita grande dos dois lados |
| `skills/engineering/README.md` | Lista de skills do bucket diverge |
| `skills/engineering/ask-skills/SKILL.md` | **O grande**: rename `ask-matt`→`ask-skills` (seu) vs. expansão de conteúdo do `ask-matt` (deles), no mesmo arquivo |
| `skills/engineering/tdd/SKILL.md` | Mudança de filosofia do TDD (remoção da etapa refactor) colidindo com qualquer alteração local sua nesse arquivo |

---

## 4. Pontos que merecem decisão sua antes de resolver

1. **`ask-skills` vs `ask-matt`**: você quer manter o nome `ask-skills` (e vai precisar reaplicar manualmente o conteúdo novo que o upstream colocou em `ask-matt`), ou prefere voltar a chamar `ask-matt` pra facilitar futuros syncs?
2. **`marketplace.json`**: manter sua versão (não existe mais upstream) ou abandonar já que o upstream não usa mais esse mecanismo?
3. **`tdd`**: aceitar a nova filosofia (sem etapa de refactor) ou manter a sua se você tinha customizado algo ali?
4. **Buckets promovidos/não-promovidos em `CLAUDE.md`/`README.md`**: upstream introduziu o conceito de "promoted buckets" com páginas de docs por skill (`docs/<bucket>/<skill>.md`) — decidir se você quer adotar essa convenção de documentação também.
