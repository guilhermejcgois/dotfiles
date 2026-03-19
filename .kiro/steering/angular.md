---
inclusion: fileMatch
fileMatchPattern: "**/{angular.json,app.module.ts,*.component.ts,*.component.html,*.module.ts}"
---

# Diretrizes para Angular

## Estrutura de Módulos e Componentes

- Use **Standalone Components** (Angular 17+) ao invés de NgModules quando possível.
- Organize por feature/domínio: `features/`, `shared/`, `core/`.
- Siga a convenção de nomenclatura: `feature-name.component.ts`, `feature-name.service.ts`.

```typescript
// ✅ Standalone Component
@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './user-profile.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserProfileComponent {
  // Use signals para estado reativo (Angular 17+)
  user = signal<User | null>(null);
  isLoading = signal(false);
}
```

## Reatividade

- Prefira **Signals** (`signal`, `computed`, `effect`) para estado local (Angular 17+).
- Use `OnPush` como estratégia de detecção de mudanças padrão.
- Use `async` pipe no template ao invés de `.subscribe()` no componente.
- Cancele subscriptions com `takeUntilDestroyed()` ou `DestroyRef`.

## Formulários

- Prefira **Reactive Forms** a Template-Driven Forms para lógica complexa.
- Use `FormBuilder` e tipagem com `FormGroup<T>`.
- Valide no modelo, não no template.

## Services e Estado

- Services são `providedIn: 'root'` por padrão.
- Use `NgRx` ou `@ngrx/signals` para estado global complexo.
- Isole chamadas HTTP em services dedicados (nunca em componentes).

## Estilização

- Prefira **Tailwind CSS** para projetos novos.
- Se usar CSS Modules ou SCSS scoped, nomeie classes em kebab-case.
- Evite estilos inline exceto para valores dinâmicos.
- Use variáveis CSS para design tokens (cores, espaçamento, tipografia).
