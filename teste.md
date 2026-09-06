# Auditoria de Más Práticas e Débito Técnico

Faça uma revisão técnica do projeto com foco em **identificar, mapear e priorizar más práticas de programação e débito técnico**.

O projeto cresceu de forma orgânica ao longo do tempo, então não quero uma grande refatoração de uma vez. O objetivo é entender **quais são os piores pontos atuais do código**, para que possamos corrigi-los gradualmente e tornar o projeto mais fácil de manter e evoluir.

## Objetivo principal

Analise o projeto como um todo e identifique problemas que possam:

* dificultar a manutenção;
* aumentar a complexidade do desenvolvimento;
* gerar bugs ou comportamentos inesperados;
* dificultar testes;
* aumentar o acoplamento entre partes do sistema;
* gerar duplicação de código;
* dificultar a compreensão das regras de negócio;
* tornar futuras alterações mais arriscadas;
* criar dependências desnecessárias;
* reduzir a escalabilidade ou performance;
* dificultar a entrada de novos desenvolvedores no projeto.

Não quero que você corrija tudo imediatamente. **Primeiro faça um diagnóstico e construa um mapa de problemas.**

---

## O que analisar

Percorra a arquitetura e o código procurando, entre outros:

### 1. Arquitetura

Identifique:

* responsabilidades mal distribuídas;
* componentes/módulos com responsabilidades demais;
* acoplamento excessivo;
* dependências circulares;
* violações de separação de responsabilidades;
* regras de negócio espalhadas pela aplicação;
* lógica duplicada em diferentes camadas;
* abstrações desnecessárias ou inexistentes;
* padrões arquiteturais inconsistentes.

### 2. Código

Procure:

* funções/métodos excessivamente grandes;
* classes/componentes muito complexos;
* código duplicado;
* condicionais excessivamente complexas;
* `if/else` aninhados em excesso;
* valores mágicos;
* constantes espalhadas;
* nomes pouco claros;
* responsabilidades misturadas;
* código difícil de testar;
* código morto ou aparentemente obsoleto;
* comentários utilizados para explicar código que deveria ser autoexplicativo;
* tratamentos de erro inconsistentes;
* soluções improvisadas que se tornaram permanentes.

### 3. Regras de negócio

Preste atenção especial às regras de negócio.

Identifique:

* regras duplicadas;
* regras implementadas em lugares diferentes;
* regras escondidas dentro de componentes ou controllers;
* comportamentos implícitos;
* exceções implementadas como "gambiarras";
* regras que dependem de ordem de execução;
* comportamentos que parecem ter sido definidos arbitrariamente no código;
* inconsistências entre diferentes partes do sistema.

Quando encontrar uma regra que pareça importante, explique **onde ela está implementada e quais partes do sistema dependem dela**.

### 4. Manutenibilidade

Identifique pontos em que uma alteração aparentemente simples exige modificar vários lugares do sistema.

Procure principalmente por:

* alto acoplamento;
* baixa coesão;
* efeitos colaterais;
* dependências implícitas;
* lógica espalhada;
* componentes muito reutilizados que ficaram complexos;
* funções que fazem coisas demais.

### 5. Testabilidade

Avalie:

* partes importantes sem testes;
* código difícil de testar;
* dependências difíceis de mockar;
* regras de negócio acopladas à infraestrutura;
* funções com muitos efeitos colaterais;
* ausência de testes para comportamentos críticos.

Não considere simplesmente "não existe teste" como um problema isolado. Priorize aquilo que **deveria possuir testes devido ao risco ou complexidade**.

### 6. Performance

Identifique problemas evidentes ou potenciais, como:

* consultas desnecessárias;
* N+1 queries;
* processamento repetido;
* chamadas externas desnecessárias;
* carregamento excessivo de dados;
* operações que poderiam ser cacheadas;
* processamento no lugar errado.

Não faça otimizações prematuras. Diferencie problemas reais de possíveis otimizações.

### 7. Segurança e robustez

Procure más práticas relacionadas a:

* validação insuficiente;
* autorização;
* autenticação;
* exposição de dados;
* tratamento inadequado de erros;
* informações sensíveis em código;
* dependências inseguras ou utilizadas de maneira inadequada.

---

# Como apresentar os resultados

Não quero apenas uma lista genérica de "boas práticas".

Para cada problema encontrado, apresente:

### Problema

Descreva objetivamente o que está errado.

### Localização

Informe exatamente onde o problema está:

* arquivo;
* classe/componente;
* função/método;
* módulo, quando aplicável.

### Por que é um problema

Explique o impacto técnico e, quando possível, dê um exemplo de como isso dificulta a manutenção ou evolução.

### Severidade

Classifique como:

* 🔴 **Crítico** — deve ser tratado prioritariamente;
* 🟠 **Alto** — gera risco ou dificuldade significativa;
* 🟡 **Médio** — merece melhoria, mas não precisa ser urgente;
* 🟢 **Baixo** — melhoria de qualidade/convenção.

### Esforço

Estime:

* **Baixo**
* **Médio**
* **Alto**

### Impacto da correção

Classifique como:

* **Alto**
* **Médio**
* **Baixo**

### Estratégia de melhoria

Sugira como corrigir o problema sem exigir uma grande reescrita do sistema.

Priorize **refatorações incrementais e de baixo risco**.

---

# Priorização

Ao final, crie um ranking dos problemas encontrados.

Priorize considerando:

**Impacto × risco × frequência × dificuldade de manutenção × esforço para corrigir.**

Quero principalmente descobrir:

1. Quais são os 5 problemas mais prejudiciais atualmente?
2. Quais problemas geram maior risco de bugs?
3. Quais problemas mais dificultam o desenvolvimento de novas funcionalidades?
4. Quais problemas podem ser corrigidos com pouco esforço e gerar grande benefício?
5. Quais problemas deveriam ser resolvidos antes de continuar adicionando funcionalidades?

Monte uma tabela semelhante a:

| Prioridade | Problema | Local | Severidade | Impacto | Esforço | Recomendação |
| ---------- | -------- | ----- | ---------- | ------- | ------- | ------------ |
| 1          | ...      | ...   | 🔴 Crítico | Alto    | Médio   | ...          |
| 2          | ...      | ...   | 🟠 Alto    | Alto    | Baixo   | ...          |

---

# Plano de evolução

Depois do diagnóstico, proponha um **plano incremental de limpeza do projeto**.

Organize em:

### Fase 1 — Quick wins

Problemas fáceis de corrigir e com alto benefício.

### Fase 2 — Redução de complexidade

Refatorações que simplifiquem partes importantes do código.

### Fase 3 — Arquitetura

Problemas estruturais que exigem mais cuidado.

### Fase 4 — Evolução contínua

Práticas que devemos adotar para evitar que o código volte a acumular os mesmos problemas.

---

## Regras importantes

* **Não faça uma refatoração geral.**
* **Não proponha mudanças apenas por preferência pessoal ou estilo.**
* Diferencie claramente uma **má prática real** de uma simples diferença de estilo.
* Não recomende reescrever partes do sistema sem justificar o benefício.
* Considere o contexto atual do projeto e suas dependências.
* Prefira mudanças pequenas, incrementais e seguras.
* Preserve o comportamento atual do sistema sempre que possível.
* Não assuma que uma solução é ruim apenas porque não segue determinado padrão arquitetural.
* Sempre que possível, apresente evidências concretas no código.
* Se encontrar uma decisão que parece estranha, mas pode ser uma regra de negócio intencional, marque-a como **"precisa de validação"** em vez de afirmar que está errada.
* Evite transformar a análise em uma lista infinita de pequenos problemas. **Priorize os problemas que realmente impactam a evolução do sistema.**

## Resultado esperado

Quero terminar esta análise com um **mapa de débito técnico do projeto**, sabendo:

* onde estão os principais problemas;
* por que eles são problemas;
* quais são mais importantes;
* quais podem ser corrigidos primeiro;
* qual o esforço aproximado;
* e qual estratégia incremental usar para melhorar o projeto sem precisar parar o desenvolvimento.
