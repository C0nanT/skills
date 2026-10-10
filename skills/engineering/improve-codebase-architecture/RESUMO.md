# Resumo: improve-codebase-architecture

**O que faz:** varre a base de código em busca de módulos rasos que valem a pena aprofundar, dando prioridade aos trechos que mudaram recentemente. Gera um relatório HTML visual (em `$TMPDIR`, nunca no repositório) com um cartão por candidato, com arquivos, problema, solução, benefícios, diagrama antes/depois e força da recomendação. Depois de você escolher um candidato, faz um grilling sobre ele e atualiza o `GLOSSARY.md` e, quando faz sentido, oferece registrar decisões como ADRs.

**Quando usar:** quando você quer melhorar a testabilidade ou a navegabilidade da arquitetura, ou quer uma visão de onde estão os pontos de atrito.

**Como invocar:** `/improve-codebase-architecture`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `HTML-REPORT.md` / `HTML-REPORT.pt-BR.md` (esqueleto do relatório, em inglês e em português) e este `RESUMO.md`.
