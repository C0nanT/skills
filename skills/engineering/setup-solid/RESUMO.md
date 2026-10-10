# Resumo: setup-solid

**O que faz:** escreve uma seção SOLID no nível de arquitetura no `CLAUDE.md` (ou `AGENTS.md`) do repositório. A seção define que SOLID vale para o código novo e para o código que cada mudança toca (regra do escoteiro), e não para o repositório inteiro. Ela nomeia os caminhos reais de política (domínio) e de detalhes (IO), a forma de injeção e a forma de substituição em testes. Antes de escrever, explora o repositório, mostra o rascunho e confere conflitos com seções de padrões existentes e com ADRs.

**Quando usar:** uma vez por repositório, se você quer que todas as skills seguintes sigam princípios SOLID ao escrever e revisar código. Não faz nada em repositórios sem camadas de política e detalhes (documentação, scripts, arquivos de prompt).

**Como invocar:** `/setup-solid`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
