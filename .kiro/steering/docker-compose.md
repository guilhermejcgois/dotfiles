---
inclusion: fileMatch
fileMatchPattern: "**/docker-compose*.{yml,yaml}"
---

# Diretrizes para Docker e Docker Compose

## Estrutura de Arquivos

- Use `docker-compose.yml` como configuração base e `docker-compose.override.yml` para desenvolvimento local.
- Para ambientes separados: `docker-compose.yml` (base), `docker-compose.dev.yml`, `docker-compose.prod.yml`.
- Nunca commite arquivos com dados sensíveis; use variáveis de ambiente e `.env`.

## Boas Práticas no docker-compose.yml

```yaml
# Sempre especifique versão de imagem explícita (evite "latest")
services:
  app:
    image: node:22-alpine
    # Use build context quando tiver Dockerfile local
    build:
      context: .
      dockerfile: Dockerfile
      target: development  # multi-stage build
    # Defina recursos para evitar consumo excessivo
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    # Variáveis via .env ou env_file
    env_file:
      - .env
    environment:
      - NODE_ENV=development
    # Volumes nomeados para persistência
    volumes:
      - app_data:/app/data
      - .:/app:delegated        # mount do código em dev
      - /app/node_modules       # anonymous volume para node_modules
    # Healthcheck para dependências
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    # Dependências com condição de saúde
    depends_on:
      db:
        condition: service_healthy

volumes:
  app_data:
    driver: local
```

## Dockerfile — Multi-stage Build

```dockerfile
# Stage 1: dependências
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile

# Stage 2: build
FROM deps AS builder
COPY . .
RUN npm run build

# Stage 3: produção (imagem mínima)
FROM node:22-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY --from=deps /app/node_modules ./node_modules
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]

# Stage 4: desenvolvimento
FROM deps AS development
COPY . .
CMD ["npm", "run", "start:dev"]
```

## Banco de Dados

- Sempre defina `healthcheck` em serviços de banco para que dependentes aguardem prontidão.
- Use volumes nomeados para persistência de dados do banco.
- Exponha portas de banco apenas em desenvolvimento (não em produção).

## Redes

- Crie redes customizadas para isolar grupos de serviços.
- Use `internal: true` em redes que não precisam de acesso externo.

```yaml
networks:
  backend:
    driver: bridge
  frontend:
    driver: bridge
```

## Variáveis de Ambiente

- Mantenha um `.env.example` atualizado com todas as variáveis necessárias.
- Nunca use valores padrão inseguros (ex.: senhas como "password" ou "123456").
- Use `${VARIABLE:-default}` para valores padrão não-sensíveis.

## Performance em Desenvolvimento

- Use `delegated` ou `cached` para mounts no macOS/Windows.
- Aproveite BuildKit: `DOCKER_BUILDKIT=1` e `COMPOSE_DOCKER_CLI_BUILD=1`.
- Use `.dockerignore` para excluir `node_modules`, `.git`, `dist`, logs.

## Padrão de .dockerignore

```
node_modules
dist
build
.git
.env
.env.*
*.log
coverage
.nyc_output
```
