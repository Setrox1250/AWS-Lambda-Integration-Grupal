# modules/compute

IAM (2 roles independientes), 2 funciones Lambda (Upload y Crop), 2 Log Groups (14 dias) y el Event Source Mapping SQS -> Crop.

## Proposito
- **Upload** (256 MB, 30 s): recibe la peticion de API Gateway y guarda en `uploads/`.
- **Crop** (512 MB, 60 s): lee `uploads/`, genera PNG circular 40x40 y escribe en `processed/`.
- Ambas asociadas a las dos subnets privadas; son **2 recursos `aws_lambda_function`**, no 4.

## Variables
| Nombre | Tipo | Default | Descripcion |
|---|---|---|---|
| environment | string | - | dev, qa o prod |
| name_prefix | string | - | `image-processor-<env>` |
| private_subnet_ids | list(string) | - | exactamente 2 subnets privadas |
| upload_lambda_sg_id / crop_lambda_sg_id | string | - | SG de cada Lambda |
| bucket_id / bucket_arn | string | - | bucket S3 |
| main_queue_arn | string | - | cola SQS principal |
| upload_zip_path / crop_zip_path | string | - | ZIP construidos para Linux |
| runtime | string | nodejs20.x | segun Mermaid |
| log_retention_days | number | 14 | retencion de logs |

## Outputs
`upload_function_arn`, `upload_invoke_arn`, `upload_function_name`, `crop_function_arn`, `crop_function_name`, `upload_log_group_name`, `crop_log_group_name`.

## Validacion
```bash
terraform fmt -recursive
terraform -chdir=modules/compute init -backend=false
terraform -chdir=modules/compute validate
```

## Riesgos
- `nodejs20.x` esta deprecado en 2026: mantener mientras AWS permita crearlo; documentar cambio a `nodejs22.x` en 09-DECISIONES-Y-RIESGOS.md.
- Lambdas en VPC crean ENIs: el `destroy` puede tardar varios minutos.
- SQS Standard entrega "al menos una vez": Crop es idempotente (clave de salida determinista).
- El Event Source Mapping lo gestiona Lambda; no usa el VPC Endpoint de SQS.