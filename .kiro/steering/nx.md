---
inclusion: fileMatch
fileMatchPattern: "**/nx.json"
---

# Diretrizes para NX Monorepo

## Estrutura de Workspace

- Organize projetos em `apps/` (aplicações implantáveis) e `libs/` (bibliotecas compartilhadas).
- Bibliotecas devem ser categorizadas por escopo e tipo:

```
apps/
├── web/          # Aplicação frontend (Next.js/Angular)
├── api/          # API backend (NestJS)
└── mobile/       # Aplicação mobile (React Native)
libs/
├── shared/
│   ├── ui/             # Componentes de UI genéricos
│   ├── util/           # Utilitários compartilhados
│   └── data-access/    # Lógica de acesso a dados
├── feature/
│   ├── auth/           # Feature de autenticação
│   └── users/          # Feature de usuários
└── domain/
    └── core/           # Modelos e regras de domínio
```

## Tags e Limites de Dependência

- Aplique tags a todos os projetos no `project.json`:

```json
{
  "tags": ["scope:web", "type:feature"]
}
```

- Configure `@nx/enforce-module-boundaries` no ESLint para garantir arquitetura:

```json
{
  "rules": {
    "@nx/enforce-module-boundaries": [
      "error",
      {
        "depConstraints": [
          { "sourceTag": "type:app", "onlyDependOnLibsWithTags": ["type:feature", "type:ui", "type:util", "type:data-access"] },
          { "sourceTag": "type:feature", "onlyDependOnLibsWithTags": ["type:ui", "type:util", "type:data-access", "type:domain"] },
          { "sourceTag": "type:ui", "onlyDependOnLibsWithTags": ["type:util", "type:domain"] },
          { "sourceTag": "scope:web", "onlyDependOnLibsWithTags": ["scope:web", "scope:shared"] },
          { "sourceTag": "scope:api", "onlyDependOnLibsWithTags": ["scope:api", "scope:shared"] }
        ]
      }
    ]
  }
}
```

## Geração de Código

- Use os geradores do NX para criar apps e libs (mantém consistência):

```bash
# Criar app Next.js
nx g @nx/next:app web --directory=apps/web

# Criar app NestJS
nx g @nx/nest:app api --directory=apps/api

# Criar biblioteca compartilhada
nx g @nx/js:lib shared-util --directory=libs/shared/util --bundler=swc

# Criar biblioteca de UI React
nx g @nx/react:lib ui-components --directory=libs/shared/ui
```

## Targets e Cache

- Configure `inputs` e `outputs` nos targets para cache eficiente:

```json
{
  "targets": {
    "build": {
      "inputs": ["production", "^production"],
      "outputs": ["{projectRoot}/dist"],
      "cache": true
    },
    "test": {
      "inputs": ["default", "^production", "{workspaceRoot}/jest.preset.js"],
      "cache": true
    }
  }
}
```

- Use **Nx Cloud** ou cache distribuído para times/CI.

## Execução Eficiente

```bash
# Executar apenas projetos afetados pela mudança
nx affected:test
nx affected:build
nx affected:lint

# Executar em paralelo (aproveitar multi-core)
nx run-many --target=test --all --parallel=4

# Visualizar grafo de dependências
nx graph

# Ver o que seria afetado sem executar
nx affected:graph
```

## Versionamento (Nx Release)

- Use `nx release` para versionamento coordenado de bibliotecas publicadas.
- Configure `nx.json` para definir grupos de versioning.

## Configuração de CI

```yaml
# .github/workflows/ci.yml
- name: Set NX SHAs
  uses: nrwl/nx-set-shas@v4

- name: Build affected
  run: npx nx affected --target=build --base=$NX_BASE --head=$NX_HEAD

- name: Test affected
  run: npx nx affected --target=test --base=$NX_BASE --head=$NX_HEAD
```

## Boas Práticas

- Nunca importe diretamente de paths internos de outra lib — use o index de barrel (`@scope/lib-name`).
- Mantenha bibliotecas com baixo acoplamento e alta coesão.
- Mova código compartilhado para libs assim que for usado por 2+ projetos.
- Use `nx sync` após adicionar plugins para sincronizar configurações.
