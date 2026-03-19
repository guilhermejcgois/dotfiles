---
inclusion: fileMatch
fileMatchPattern: "**/*.{tf,tfvars,tfvars.json}"
---

# Diretrizes para Terraform

## Estrutura de Módulos

- Separe infraestrutura por **ambiente** (`envs/`) e **módulos reutilizáveis** (`modules/`).
- Nunca duplique código — encapsule recursos relacionados em módulos.

```
infrastructure/
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecs-service/
    └── rds/
```

## Convenções de Nomenclatura

- Use **snake_case** para todos os identificadores Terraform.
- Nomeie recursos com padrão: `{projeto}-{ambiente}-{recurso}`.
- Variáveis e outputs devem ter `description` e `type` explícitos.

```hcl
# ✅ Bom
resource "aws_s3_bucket" "app_assets" {
  bucket = "${var.project_name}-${var.environment}-assets"

  tags = local.common_tags
}

# ❌ Evitar
resource "aws_s3_bucket" "b" {
  bucket = "mybucket123"
}
```

## Variáveis

- Sempre defina `type`, `description` e, quando aplicável, `validation`.
- Separe variáveis obrigatórias das opcionais (com `default`).
- Use `.tfvars` por ambiente; nunca commite valores sensíveis.

```hcl
variable "environment" {
  description = "Ambiente de implantação (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser dev, staging ou prod."
  }
}

variable "instance_count" {
  description = "Número de instâncias ECS"
  type        = number
  default     = 1
}
```

## State e Backend

- Use sempre **remote state** (S3 + DynamoDB para AWS) com locking.
- Configure state por ambiente para isolamento.
- Nunca commite arquivos `.tfstate`.

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-minha-empresa"
    key            = "projeto/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Locals e Tags

- Use `locals` para valores calculados e tags comuns.
- Aplique tags em todos os recursos AWS para rastreabilidade.

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.team_name
  }

  name_prefix = "${var.project_name}-${var.environment}"
}
```

## Outputs

- Exporte valores necessários para outros módulos ou uso externo.
- Marque outputs sensíveis com `sensitive = true`.

```hcl
output "database_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = aws_db_instance.main.endpoint
}

output "database_password" {
  description = "Senha do banco de dados"
  value       = random_password.db.result
  sensitive   = true
}
```

## Segurança

- Use **IAM roles** com menor privilégio — nunca IAM users com chaves de longa duração em produção.
- Habilite encryption at rest em todos os recursos de storage (S3, RDS, EBS).
- Use **Security Groups** restritivos — deny por padrão, allow explícito.
- Rotacione segredos com AWS Secrets Manager; não hardcode valores sensíveis.
- Habilite VPC flow logs e CloudTrail.

```hcl
# ✅ Bucket S3 seguro
resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket                  = aws_s3_bucket.app_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

## Fluxo de Trabalho

```bash
# Formatar código
terraform fmt -recursive

# Validar configuração
terraform validate

# Planejar mudanças
terraform plan -var-file="envs/dev/terraform.tfvars" -out=tfplan

# Revisar e aplicar
terraform show tfplan
terraform apply tfplan

# Verificar estado
terraform state list
```

## Boas Práticas

- Execute `terraform fmt` e `terraform validate` antes de commitar.
- Use **tflint** e **tfsec/checkov** no CI para linting e segurança.
- Versione os providers com `~>` (patch updates automáticas, minor bloqueado).
- Revise o `plan` cuidadosamente antes de `apply` em produção.
- Prefira `terraform destroy` a remoção manual de recursos do state.
