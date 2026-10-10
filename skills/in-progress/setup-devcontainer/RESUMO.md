# Resumo: setup-devcontainer

**O que faz:** cria um devcontainer para o repositório como um **serviço `workspace` da stack Compose** do projeto, atrás de um profile. Assim o container alcança os serviços pelo nome da rede, o host fica sem toolchain e o git, as CLIs de agentes e as credenciais do host funcionam dentro do container sem novo login. A skill explora o repositório e o host (UID/GID, socket do Docker, caminhos de configuração), pergunta só o que se ramifica (acesso ao socket, CLI de tracker remoto, ferramentas extras, CLIs de agentes), confere cada tag de imagem, escreve os arquivos na ordem certa e verifica o resultado, incluindo o teste de que o container realmente é recriado.

**Quando usar:** em um repositório novo, antes de instalar qualquer ferramenta no host, ou para migrar um `.devcontainer/` existente.

**Como invocar:** `/setup-devcontainer`. É uma skill só para o usuário (`disable-model-invocation: true`). Está em `in-progress/`, ou seja, é beta.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `REFERENCE.md` / `REFERENCE.pt-BR.md` (raciocínio das montagens, tabela de falhas e anti-padrões, em inglês e em português) e este `RESUMO.md`.
