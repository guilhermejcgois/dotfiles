---
inclusion: fileMatch
fileMatchPattern: "**/{main.ts,app.module.ts,*.module.ts,*.controller.ts,*.service.ts,*.guard.ts,*.interceptor.ts,*.decorator.ts}"
---

# Diretrizes para NestJS

## Estrutura de Módulos

- Organize por **domínio/feature**, não por tipo técnico.
- Cada módulo deve ser autocontido com seu controller, service, repository e DTOs.

```
src/
├── app.module.ts
├── main.ts
├── config/             # ConfigModule, variáveis de ambiente
├── common/             # Guards, interceptors, pipes, decorators globais
│   ├── guards/
│   ├── interceptors/
│   ├── pipes/
│   └── decorators/
├── database/           # Configuração TypeORM / Kysely
└── modules/
    ├── auth/
    │   ├── auth.module.ts
    │   ├── auth.controller.ts
    │   ├── auth.service.ts
    │   ├── strategies/
    │   └── dto/
    └── users/
        ├── users.module.ts
        ├── users.controller.ts
        ├── users.service.ts
        ├── users.repository.ts
        ├── entities/
        │   └── user.entity.ts
        └── dto/
            ├── create-user.dto.ts
            └── update-user.dto.ts
```

## Configuração de Ambiente

- Use `@nestjs/config` com `ConfigService` para variáveis de ambiente.
- Valide variáveis de ambiente na inicialização com `Zod` para tipagem segura e mensagens claras.
- Crie interfaces tipadas derivadas dos schemas Zod.

```typescript
// config/env.schema.ts
import { z } from 'zod';

export const EnvSchema = z.object({
  PORT: z.coerce.number().default(3000),
  DB_HOST: z.string().min(1),
  DB_PORT: z.coerce.number().default(5432),
  DB_NAME: z.string().min(1),
});

export type Env = z.infer<typeof EnvSchema>;

// config/app.config.ts
export const appConfig = () => {
  const env = EnvSchema.parse(process.env);
  return {
    port: env.PORT,
    database: { host: env.DB_HOST, port: env.DB_PORT, name: env.DB_NAME },
  };
};

// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [appConfig] }),
  ],
})
export class AppModule {}
```

## Controllers

- Mantenha controllers finos — apenas roteamento e parsing de entrada.
- Use Zod schemas com um `ZodValidationPipe` customizado para validar o body.
- Aplique decorators de documentação Swagger em todos os endpoints.

```typescript
@ApiTags('users')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @ApiOperation({ summary: 'Criar usuário' })
  @ApiResponse({ status: 201, type: UserResponseDto })
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto);
  }

  @Get(':id')
  @ApiParam({ name: 'id', type: String, format: 'uuid' })
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    return this.usersService.findOneOrThrow(id);
  }
}
```

## Services

- Services contêm a lógica de negócio.
- Injete dependências pelo construtor (nunca instancie manualmente).
- Lance exceptions do NestJS (`NotFoundException`, `BadRequestException`, etc.).

```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findOneOrThrow(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`Usuário com ID ${id} não encontrado`);
    }
    return user;
  }
}
```

## DTOs e Validação com Zod

- Use **Zod** para definir schemas de request e inferir tipos TypeScript.
- Crie um `ZodValidationPipe` global que valida o body com o schema correspondente.
- Separe schemas de input e tipos de response.

```typescript
// users/dto/create-user.schema.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z
    .string()
    .min(8)
    .regex(/^(?=.*[A-Z])(?=.*\d)/, 'Senha deve ter maiúscula e número'),
});

export type CreateUserDto = z.infer<typeof CreateUserSchema>;

// common/pipes/zod-validation.pipe.ts
import { PipeTransform, BadRequestException } from '@nestjs/common';
import { ZodSchema } from 'zod';

/** Use este pipe diretamente em parâmetros @Body() para validação de entrada. */
export class ZodValidationPipe implements PipeTransform {
  constructor(private readonly schema: ZodSchema) {}

  transform(value: unknown) {
    const result = this.schema.safeParse(value);
    if (!result.success) {
      const errors = result.error.issues.map((issue) => ({
        field: issue.path.join('.'),
        message: issue.message,
      }));
      throw new BadRequestException({ message: 'Dados inválidos', errors });
    }
    return result.data;
  }
}

// users/users.controller.ts
@Post()
async create(
  @Body(new ZodValidationPipe(CreateUserSchema)) dto: CreateUserDto,
): Promise<UserResponseDto> {
  return this.usersService.create(dto);
}
```

## Interceptors e Guards

- Use interceptors para transformação de response, logging, cache.
- Use guards para autenticação e autorização.
- Aplique globalmente via `APP_INTERCEPTOR` e `APP_GUARD` no AppModule.

```typescript
// main.ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new LoggingInterceptor());

  const config = new DocumentBuilder()
    .setTitle('API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(3000);
}
```

## Banco de Dados com TypeORM e Kysely

- Use **TypeORM** com Repository Pattern e `@InjectRepository` para entidades relacionais.
- Use **Kysely** para queries SQL complexas que se beneficiam de type-safety total no nível de query.
- Nunca use `synchronize: true` em produção — use migrations sempre.
- Nunca escreva SQL raw desnecessário — prefira o query builder do TypeORM ou a API fluente do Kysely.

```typescript
// Exemplo TypeORM — repository pattern
@Injectable()
export class UsersRepository {
  constructor(
    @InjectRepository(User)
    private readonly repo: Repository<User>,
  ) {}

  async findActiveByEmail(email: string): Promise<User | null> {
    return this.repo.findOne({ where: { email, active: true } });
  }
}

// Exemplo Kysely — query complexa tipada
@Injectable()
export class ReportsRepository {
  constructor(private readonly db: Kysely<Database>) {}

  async getOrderSummaryByCustomer(since: Date) {
    return this.db
      .selectFrom('orders as o')
      .innerJoin('customers as c', 'c.id', 'o.customer_id')
      .select([
        'c.id as customerId',
        'c.name as customerName',
        (eb) => eb.fn.count<number>('o.id').as('orderCount'),
        (eb) => eb.fn.sum<number>('o.total').as('totalAmount'),
      ])
      .where('o.created_at', '>=', since)
      .groupBy(['c.id', 'c.name'])
      .orderBy('totalAmount', 'desc')
      .execute();
  }
}
```

## Testes

- Use `@nestjs/testing` com `Test.createTestingModule()`.
- Mock dependências com `jest.fn()` e `jest.spyOn()`.
- Escreva testes e2e com `supertest` para endpoints críticos.

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<Repository<User>>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: { findOne: jest.fn() } },
      ],
    }).compile();

    service = module.get(UsersService);
    repo = module.get(getRepositoryToken(User));
  });

  it('deve lançar NotFoundException quando usuário não existe', async () => {
    repo.findOne.mockResolvedValue(null);
    await expect(service.findOneOrThrow('uuid')).rejects.toThrow(NotFoundException);
  });
});
```
