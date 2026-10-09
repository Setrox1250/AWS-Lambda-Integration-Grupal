# modules/network/README.md

# Módulo: `network`

**Propietaria:** Tamara Solano  
**Rama:** `feat/network-aws`  
**Revisado por:** Diego Rodriguez

## Propósito

Implementa la topología de red completa descrita en el Mermaid del profesor para la región `us-east-1`. Crea todos los recursos de VPC necesarios para aislar las funciones Lambda en subnets privadas con acceso saliente a S3 y SQS a través de VPC Endpoints, sin exponer tráfico a Internet.

## Recursos creados

| Recurso Terraform | Nombre en AWS | Descripción |
|---|---|---|
| `aws_vpc` | `{prefix}-vpc` | VPC con DNS support y hostnames |
| `aws_internet_gateway` | `{prefix}-igw` | Entry point para tráfico público |
| `aws_subnet` × 4 | `{prefix}-public-a/b`, `{prefix}-private-a/b` | 2 públicas y 2 privadas en AZ-a y AZ-b |
| `aws_eip` × 2 | `{prefix}-eip-nat-a/b` | IPs elásticas para los NAT Gateways |
| `aws_nat_gateway` × 2 | `{prefix}-nat-a/b` | Uno por AZ, en subred pública |
| `aws_route_table` × 3 | `{prefix}-rt-public`, `rt-private-a/b` | Tabla pública comparte IGW; privadas tienen NAT independiente |
| `aws_vpc_endpoint` (Gateway) | `{prefix}-vpce-s3` | Endpoint gratuito para S3, sin ENI |
| `aws_vpc_endpoint` (Interface) | `{prefix}-vpce-sqs` | Endpoint con ENI en ambas subnets privadas |
| `aws_security_group` × 3 | `sg-upload-lambda`, `sg-crop-lambda`, `sg-vpce-sqs` | SGs con reglas mínimas |

## Topología de red

```
Internet
   │
   ▼
[IGW]
   ├── Public Subnet AZ-a (10.0.1.0/24)  ──▶ [NAT-A] ──▶ EIP-A
   └── Public Subnet AZ-b (10.0.2.0/24)  ──▶ [NAT-B] ──▶ EIP-B

Private Subnet AZ-a (10.0.11.0/24) ──▶ rt-private-a (0.0.0.0/0 → NAT-A)
Private Subnet AZ-b (10.0.12.0/24) ──▶ rt-private-b (0.0.0.0/0 → NAT-B)

S3 Gateway Endpoint ──▶ inyectado en rt-private-a y rt-private-b
SQS Interface Endpoint ──▶ ENI en private-a y private-b
```

## Variables

| Variable | Tipo | Default | Descripción |
|---|---|---|---|
| `environment` | `string` | **requerido** | `dev`, `qa` o `prod` |
| `name_prefix` | `string` | **requerido** | `image-processor-<environment>` |
| `vpc_cidr` | `string` | `10.0.0.0/16` | CIDR de la VPC |
| `aws_region` | `string` | `us-east-1` | Región AWS |
| `bucket_arn` | `string` | `""` | ARN del bucket S3 para policy del Gateway Endpoint |

## Outputs (contrato)

| Output | Descripción |
|---|---|
| `vpc_id` | ID de la VPC |
| `public_subnet_ids` | Lista `[az-a, az-b]` de subnets públicas |
| `private_subnet_ids` | Lista `[az-a, az-b]` de subnets privadas |
| `sg_upload_lambda_id` | ID de `sg-upload-lambda` |
| `sg_crop_lambda_id` | ID de `sg-crop-lambda` |
| `s3_endpoint_id` | ID del Gateway Endpoint de S3 |
| `sqs_endpoint_id` | ID del Interface Endpoint de SQS |
| `nat_gateway_ids` | Lista `[nat-a, nat-b]` |
| `eip_allocation_ids` | Lista `[eip-a, eip-b]` |
| `private_route_table_ids` | Lista `[rt-private-a, rt-private-b]` |
| `vpc_cidr` | CIDR de la VPC |
| `availability_zones` | Lista de AZs usadas |

## Validación local (sin AWS)

```bash
terraform fmt -recursive
terraform -chdir=modules/network init -backend=false
terraform -chdir=modules/network validate
```

## Riesgos documentados

1. **Costo NAT Gateway**: cada NAT cobra por hora provisionada (~$0.045/h) y por GB transferido. Con 2 NAT activos incluso 1 hora parcial genera cargo. Ejecutar `terraform destroy` inmediatamente después de las evidencias.

2. **EIP sin asociar**: una EIP asignada pero no asociada también genera cargo. El `destroy` de Terraform libera ambas EIPs automáticamente; verificar en la consola que no quedan EIPs huérfanas.

3. **Sin failover automático cruzado**: los dos NAT Gateways son independientes. Si NAT-A falla, private-a queda sin salida; no redirige automáticamente a NAT-B. Esto replica fielmente el Mermaid.

4. **SQS Interface Endpoint**: se crea por fidelidad al Mermaid. El Event Source Mapping de Lambda consume SQS como servicio administrado de AWS; el polling interno de Lambda no necesariamente pasa por la ENI del endpoint. Se mantiene por diseño de arquitectura.

5. **AZs físicas**: `data.aws_availability_zones` devuelve las AZs disponibles para la cuenta. Las letras (a, b) pueden mapear a hardware diferente entre cuentas (AZ IDs vs AZ names).

6. **Ciclo de dependencia**: `network` recibe `bucket_arn` desde `storage` como input. `storage` NO depende de `network`. El root crea `storage` primero y pasa el ARN al módulo `network`. Nunca al revés.
