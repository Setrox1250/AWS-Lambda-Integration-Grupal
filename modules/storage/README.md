# Modulo storage

Crea un bucket S3 privado por entorno, una cola SQS Standard, su DLQ y la
notificacion `ObjectCreated` sobre `uploads/`. No crea Lambdas ni VPC.

## Recursos

| Recurso | Detalle |
|---|---|
| S3 | `<name_prefix>-images-<account_id>`, AES256, versioning Enabled, acceso publico bloqueado |
| Lifecycle | `uploads/` 30 dias, `processed/` 90 dias, versiones anteriores a los 7 dias |
| SQS main | `<name_prefix>-image-queue`: visibility 360 s, retencion 1 dia, long polling 20 s |
| SQS DLQ | `<name_prefix>-image-dlq`: retencion 14 dias, redrive tras 3 recepciones |
| Policy | `s3.amazonaws.com` -> `sqs:SendMessage`, con `aws:SourceArn` y `aws:SourceAccount` |
| Evento | `s3:ObjectCreated:*` con `filter_prefix = "uploads/"` hacia la cola principal |

`processed/` no genera eventos, asi Crop no se reprocesa a si mismo.

## Variables

| Nombre | Tipo | Default | Descripcion |
|---|---|---|---|
| `environment` | string | n/a | `dev`, `qa` o `prod` |
| `name_prefix` | string | n/a | Ej. `image-processor-dev` |
| `force_destroy` | bool | `true` | Borra objetos y versiones al destruir |

## Outputs

`bucket_id`, `bucket_arn`, `uploads_prefix`, `processed_prefix`,
`main_queue_arn`, `main_queue_url`, `main_queue_name`, `dlq_arn`, `dlq_name`.

## Uso

```hcl
module "storage" {
  source      = "../../modules/storage"
  environment = var.environment
  name_prefix = local.name_prefix
}
```

## Verificacion manual (tras el apply)

```bash
BUCKET=$(terraform -chdir=envs/dev output -raw bucket_name)   # o el output que exponga el root
aws s3 ls "s3://$BUCKET/uploads/"      # imagen original
aws s3 ls "s3://$BUCKET/processed/"    # <uuid>_circular.png (40x40)
```

Revisar la DLQ **sin borrar mensajes** hasta tomar la evidencia:

```bash
aws sqs get-queue-attributes --queue-url <dlq_url> \
  --attribute-names ApproximateNumberOfMessages
aws sqs receive-message --queue-url <dlq_url> --visibility-timeout 0
```

## Riesgos

- Las notificaciones S3 son asincronas y pueden duplicarse: Crop debe ser idempotente.
- Si la queue policy es incorrecta, el `apply` de la notificacion falla o no llegan mensajes.
- `force_destroy = true` elimina datos de forma irreversible. Es valido solo por
  ser una tarea efimera; no llevarlo a produccion real.