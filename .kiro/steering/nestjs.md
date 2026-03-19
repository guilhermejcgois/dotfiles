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
├── database/           # Configuração TypeORM/Prisma
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
- Valide variáveis de ambiente na inicialização com `Joi` ou `class-validator`.
- Crie interfaces tipadas para as configurações.

```typescript
// config/app.config.ts
export const appConfig = () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  database: {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT ?? '5432', 10),
    name: process.env.DB_NAME,
  },
});

// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig],
      validationSchema: Joi.object({
        PORT: Joi.number().default(3000),
        DB_HOST: Joi.string().required(),
      }),
    }),
  ],
})
export class AppModule {}
```

## Controllers

- Mantenha controllers finos — apenas roteamento e validação de entrada.
- Use DTOs com `class-validator` para toda entrada.
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

## DTOs e Validação

- Use `class-validator` e `class-transformer` em todos os DTOs.
- Habilite `ValidationPipe` globalmente com `whitelist: true` e `forbidNonWhitelisted: true`.
- Separe DTOs de request e response.

```typescript
// create-user.dto.ts
export class CreateUserDto {
  @ApiProperty({ example: 'João Silva' })
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @ApiProperty({ example: 'joao@email.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[A-Z])(?=.*\d)/, { message: 'Senha deve ter maiúscula e número' })
  password: string;
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

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

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

## Banco de Dados com TypeORM/Prisma

- Prefira **Prisma** para projetos novos (melhor tipagem e DX).
- Com TypeORM, use Repository Pattern com `@InjectRepository`.
- Nunca escreva SQL raw desnecessário — use o query builder.
- Use migrations para mudanças de schema (nunca `synchronize: true` em produção).

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
