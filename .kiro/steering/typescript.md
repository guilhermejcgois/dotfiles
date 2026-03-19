---
inclusion: fileMatch
fileMatchPattern: "**/*.{ts,tsx}"
---

# Diretrizes para TypeScript

## Configuração (tsconfig.json)

- Sempre use `"strict": true` — ativa todas as verificações estritas.
- Prefira `"moduleResolution": "bundler"` (projetos modernos) ou `"node16"`.
- Configure `paths` para aliases de importação limpos (ex.: `@/` para `src/`).

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

## Tipos e Interfaces

- Prefira `interface` para contratos de objetos; use `type` para unions, intersections e aliases.
- Nunca use `any` — prefira `unknown` e faça narrowing explícito.
- Evite type assertions (`as`) desnecessárias; prefira type guards.
- Use `readonly` em propriedades imutáveis.
- Defina tipos de retorno explícitos em funções públicas/exportadas.

```typescript
// ✅ Bom
interface User {
  readonly id: string;
  name: string;
  email: string;
}

type Result<T, E = Error> = { success: true; data: T } | { success: false; error: E };

// ❌ Evitar
const user: any = fetchUser();
const typed = user as User;
```

## Funções e Métodos

- Prefira arrow functions para callbacks e métodos curtos.
- Use parâmetros opcionais com `?` ao invés de union com `undefined` quando possível.
- Utilize destructuring com tipos explícitos.
- Prefira `const` e imutabilidade.

```typescript
// ✅ Bom
const formatUser = ({ name, email }: Pick<User, 'name' | 'email'>): string =>
  `${name} <${email}>`;

// Use generics para funções reutilizáveis
const findById = <T extends { id: string }>(items: T[], id: string): T | undefined =>
  items.find((item) => item.id === id);
```

## Enums e Literais

- Prefira union de string literals a `enum` numérico.
- Se usar `enum`, prefira `const enum` para tree-shaking.

```typescript
// ✅ Prefira
type Status = 'active' | 'inactive' | 'pending';

// ✅ Aceitável
const enum Direction { Up = 'UP', Down = 'DOWN' }

// ❌ Evitar
enum Status { Active = 0, Inactive = 1 }
```

## Async/Await

- Use sempre `async/await` ao invés de `.then().catch()` encadeados.
- Trate erros com `try/catch` e tipage explícita do erro.
- Use `Promise.all` ou `Promise.allSettled` para paralelismo.

```typescript
const fetchData = async (id: string): Promise<User> => {
  try {
    const response = await api.get<User>(`/users/${id}`);
    return response.data;
  } catch (error) {
    if (error instanceof ApiError) {
      throw new NotFoundError(`Usuário ${id} não encontrado`);
    }
    throw error;
  }
};
```

## Organização de Módulos

- Um arquivo por classe/componente principal.
- Agrupe exports relacionados em `index.ts` (barrel exports).
- Evite importações circulares.
- Use imports absolutos com aliases configurados no tsconfig.

```typescript
// ✅ Importação absoluta
import { UserService } from '@/services/user';

// ❌ Evitar
import { UserService } from '../../../services/user';
```

## Zod para Validação em Runtime

- Use [Zod](https://zod.dev/) para validação e parsing de dados externos (API, formulários).
- Derive tipos TypeScript a partir dos schemas Zod.

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(2).max(100),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

const parseUser = (data: unknown): User => UserSchema.parse(data);
```
