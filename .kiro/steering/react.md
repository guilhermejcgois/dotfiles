---
inclusion: fileMatch
fileMatchPattern: "**/{next.config.*,*.component.tsx,*.page.tsx,*.tsx}"
---

# Diretrizes para React e Next.js

## React — Componentes

- Use **Function Components** com hooks — nunca Class Components.
- Nomeie componentes em PascalCase e arquivos em kebab-case ou PascalCase.
- Mantenha componentes pequenos e com responsabilidade única.
- Extraia lógica reutilizável em custom hooks (`use` prefix).

```tsx
// ✅ Bom
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
}

const UserCard = ({ user, onEdit }: UserCardProps) => {
  const handleEdit = useCallback(() => onEdit(user.id), [user.id, onEdit]);

  return (
    <div className="user-card">
      <h2>{user.name}</h2>
      <button onClick={handleEdit}>Editar</button>
    </div>
  );
};

export default UserCard;
```

## React — Estado e Efeitos

- Use `useState` para estado local simples.
- Use `useReducer` para estado com lógica complexa de transições.
- Use `useContext` + `useReducer` ou **Zustand** para estado global leve.
- Use **TanStack Query** (React Query) para estado de servidor/cache.
- `useEffect` deve ter dependências explícitas; evite dependências instáveis.

```typescript
// ✅ Custom Hook com TanStack Query
const useUser = (id: string) => {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => fetchUser(id),
    staleTime: 5 * 60 * 1000,
  });
};
```

## React — Performance

- Use `React.memo` para componentes que recebem props estáveis.
- Use `useMemo` e `useCallback` com moderação — só quando há custo real.
- Use `React.lazy` e `Suspense` para code splitting.
- Evite renders desnecessários causados por novos objetos/arrays inline.

---

## Next.js — App Router (Next.js 13+)

- Use **App Router** (`app/`) ao invés de Pages Router para projetos novos.
- Maximize o uso de **Server Components** — mova `use client` para folhas da árvore.
- Use Server Actions para mutações ao invés de API Routes quando possível.

```typescript
// ✅ Server Component (padrão)
const UsersPage = async () => {
  const users = await getUsers(); // fetch direto no servidor

  return <UserList users={users} />;
};

// ✅ Client Component apenas quando necessário
'use client';
const SearchInput = () => {
  const [query, setQuery] = useState('');
  // ...
};
```

## Next.js — Fetch e Cache

- Use a API `fetch` nativa com opções de cache do Next.js.
- Configure `revalidate` por rota ou por fetch.
- Use `unstable_cache` para cachear funções de banco de dados.

```typescript
// Revalidação por tempo
const getProducts = async () => {
  const res = await fetch('/api/products', { next: { revalidate: 3600 } });
  return res.json();
};
```

## Next.js — Estrutura de Pastas (App Router)

```
app/
├── (auth)/           # Route group
│   ├── login/
│   └── register/
├── (dashboard)/
│   ├── layout.tsx    # Layout compartilhado
│   ├── page.tsx
│   └── users/
│       ├── page.tsx
│       └── [id]/
│           └── page.tsx
├── api/              # Route Handlers
│   └── users/
│       └── route.ts
├── globals.css
└── layout.tsx        # Root layout
```

## Next.js — Metadados e SEO

- Use a API de `metadata` do Next.js para SEO.
- Implemente `generateMetadata` para metadados dinâmicos.
- Use `next/image` para todas as imagens (otimização automática).
- Use `next/link` para navegação interna.

---

## Estilização

- Prefira **Tailwind CSS** para projetos novos.
- Se usar CSS Modules, nomeie as classes em camelCase.
- Evite CSS inline exceto para valores dinâmicos.
- Use variáveis CSS para design tokens (cores, espaçamento, tipografia).
