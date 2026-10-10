# Resumo: wizard

**O que faz:** gera um script bash interativo que guia uma pessoa por um procedimento manual, abrindo cada URL, dizendo o que clicar e copiar, capturando valores e gravando-os no `.env` ou nos secrets do GitHub. Usa o `template.sh` como base e a skill só escreve as etapas específicas do seu caso, sem mexer na biblioteca comum.

**Quando usar:** ao provisionar infraestrutura, configurar credenciais ou secrets de CI, percorrer um painel de terceiros que você não conhece ou fazer uma migração ou troca pontual. Não serve para passos que o próprio agente consegue executar.

**Como invocar:** `/wizard`, ou o agente pode chamá-la sozinho quando a tarefa envolver esses passos (sem `disable-model-invocation`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`. Usa `template.sh` como base do script gerado (não traduzido, por ser código).
