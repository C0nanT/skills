# Resumo: setup-statusline

**O que faz:** remove da máquina a status line antiga, baseada em shell (o `statusLine` e os hooks marcados em `settings.json`, além dos scripts e do arquivo de linha de base). Depois orienta a instalar o plugin `conan-mods`, que já mostra modelo, esforço, contexto, duração, limite de taxa e branch do git, e explica como ligar, desligar e ajustar o fuso horário com `STATUSLINE_TZ`. Não instala nada por conta própria.

**Quando usar:** quando você ainda tem a status line antiga e quer migrar para o plugin.

**Como invocar:** `/setup-statusline`. É uma skill só para o usuário (`disable-model-invocation: true`). Está em `misc/`, ou seja, é de uso raro.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.
