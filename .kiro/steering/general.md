---
inclusion: always
---

# Diretrizes Gerais de Desenvolvimento

## Idioma e Comunicação

- Responda sempre em **português do Brasil (pt-BR)** a menos que explicitamente solicitado outro idioma.
- Documente código, comentários e mensagens de commit em pt-BR.
- Use inglês apenas para nomes de variáveis, funções, classes e arquivos (convenção técnica).

## Qualidade de Código

- Siga os princípios **SOLID**, **DRY** (Don't Repeat Yourself) e **KISS** (Keep It Simple, Stupid).
- Prefira **composição** a herança.
- Escreva código autoexplicativo; adicione comentários apenas quando a lógica não for óbvia.
- Mantenha funções pequenas e com responsabilidade única.
- Evite "magic numbers" — use constantes nomeadas.

## Controle de Versão

- Mensagens de commit devem seguir [Conventional Commits](https://www.conventionalcommits.org/pt-br/):
  - `feat:` nova funcionalidade
  - `fix:` correção de bug
  - `docs:` documentação
  - `refactor:` refatoração sem mudança de comportamento
  - `test:` adição ou ajuste de testes
  - `chore:` tarefas de manutenção (deps, configs)
  - `perf:` melhorias de performance
  - `ci:` mudanças em pipelines de CI/CD
- Commits devem ser atômicos e representar uma unidade lógica de trabalho.
- Use branches com prefixos: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`.

## Testes

- Escreva testes para toda lógica de negócio crítica.
- Siga o padrão **AAA** (Arrange, Act, Assert) nos testes.
- Prefira testes unitários para lógica isolada e testes de integração para fluxos completos.
- Use mocks e stubs para isolar dependências externas.
- Mantenha cobertura de testes acima de **80%** para código crítico.

## Segurança

- Nunca exponha segredos, tokens ou senhas no código-fonte.
- Use variáveis de ambiente para configurações sensíveis.
- Valide e sanitize todas as entradas do usuário.
- Aplique o princípio do menor privilégio.

## Performance

- Evite otimizações prematuras; meça antes de otimizar.
- Prefira operações assíncronas/não-bloqueantes quando aplicável.
- Considere o impacto de consultas N+1 em banco de dados.
- Use cache estrategicamente para dados frequentemente acessados.

## Estrutura de Projeto

- Organize por funcionalidade/domínio, não por tipo técnico.
- Mantenha configurações de ambiente em arquivos `.env` (nunca commitados).
- Use `.env.example` para documentar variáveis necessárias.
- Documente dependências e como iniciar o projeto no `README.md`.
