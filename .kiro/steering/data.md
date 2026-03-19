---
inclusion: fileMatch
fileMatchPattern: "**/{dbt_project.yml,*.sql,profiles.yml,schema.yml,sources.yml}"
---

# Diretrizes para DBT e SQL

## DBT — Estrutura de Projeto

- Organize os modelos em camadas bem definidas:

```
models/
├── staging/          # 1:1 com fontes brutas (limpeza e renomeação)
│   ├── _sources.yml  # Declaração das fontes
│   ├── stg_orders.sql
│   └── stg_customers.sql
├── intermediate/     # Transformações intermediárias (lógica de negócio)
│   ├── int_orders_enriched.sql
│   └── int_customer_lifetime_value.sql
├── marts/            # Modelos finais para consumo (BI, APIs)
│   ├── finance/
│   │   └── fct_revenue.sql
│   └── marketing/
│       └── dim_customers.sql
└── _models.yml       # Documentação e testes
```

## Nomenclatura de Modelos

- `stg_` — staging: limpeza de fonte, sem lógica de negócio.
- `int_` — intermediate: transformações intermediárias, não expostas ao usuário final.
- `fct_` — fact tables: eventos mensuráveis (vendas, cliques, sessões).
- `dim_` — dimension tables: entidades de negócio (clientes, produtos, locais).
- `rpt_` — report tables: modelos desnormalizados para relatórios específicos.

## Configuração de Materialização

```yaml
# dbt_project.yml
models:
  meu_projeto:
    staging:
      +materialized: view        # Views são suficientes para staging
      +schema: staging
    intermediate:
      +materialized: ephemeral   # Nunca persistidas, inlined no query
    marts:
      +materialized: table       # Tabelas para performance
      +schema: marts
      finance:
        +materialized: incremental
```

## Modelos Incrementais

- Use `incremental` para tabelas grandes de fatos.
- Sempre defina `unique_key` e `incremental_strategy`.
- Adicione filtro `is_incremental()` para processar apenas novos dados.

```sql
{{
  config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
  )
}}

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    updated_at
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
  WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

## Testes e Documentação

- Todo modelo deve ter testes básicos: `unique`, `not_null` para PKs.
- Use testes de `relationships` para FKs entre modelos.
- Documente todos os modelos e colunas críticas.

```yaml
# models/marts/_schema.yml
models:
  - name: fct_orders
    description: "Tabela de fatos de pedidos. Granularidade: um registro por pedido."
    columns:
      - name: order_id
        description: "Identificador único do pedido."
        tests:
          - unique
          - not_null
      - name: customer_id
        description: "FK para dim_customers."
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
      - name: total_amount
        description: "Valor total do pedido em BRL."
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

## SQL — Estilo e Boas Práticas

### Formatação

- Keywords em **MAIÚSCULAS**: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`.
- Uma coluna por linha em `SELECT`.
- Indente subconsultas e CTEs consistentemente.
- Use **CTEs** (`WITH`) ao invés de subconsultas aninhadas para legibilidade.

```sql
WITH base_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        SUM(item_price * quantity) AS total_amount
    FROM {{ ref('stg_order_items') }}
    GROUP BY 1, 2, 3
),

customer_info AS (
    SELECT
        customer_id,
        customer_name,
        customer_segment
    FROM {{ ref('dim_customers') }}
)

SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_name,
    c.customer_segment
FROM base_orders AS o
LEFT JOIN customer_info AS c USING (customer_id)
WHERE o.total_amount > 0
```

### Convenções de Nomenclatura SQL

- Use `snake_case` para todos os identificadores.
- Sufixos para tipos: `_id` (chaves), `_at` (timestamps), `_date` (datas), `_count` (contagens), `_amount` (valores monetários).
- Use aliases explícitos em todas as tabelas em queries com mais de um join.
- Prefira `USING` a `ON` quando os nomes das colunas são iguais.

### Performance

- Evite `SELECT *` — liste colunas explicitamente.
- Filtre o máximo possível antes de `JOIN`.
- Use `EXPLAIN ANALYZE` para identificar queries lentas.
- Considere particionamento para tabelas grandes (por data, geralmente).
- Adicione índices em colunas de filtro e join frequentes.

```sql
-- ✅ Bom: filtra antes de agregar
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
  AND status = 'completed'
GROUP BY 1

-- ❌ Evitar: agrega tudo e depois filtra
SELECT *
FROM (
    SELECT customer_id, COUNT(*) AS order_count, MAX(order_date) AS last_order
    FROM orders GROUP BY 1
) agg
WHERE last_order >= CURRENT_DATE - INTERVAL '90 days'
```

## Comandos DBT Essenciais

```bash
# Compilar e testar modelos
dbt compile
dbt run
dbt test

# Executar modelo específico e dependências
dbt run --select +meu_modelo+    # upstream + modelo + downstream
dbt run --select tag:finance     # por tag

# Freshness de fontes
dbt source freshness

# Gerar e servir documentação
dbt docs generate
dbt docs serve
```
