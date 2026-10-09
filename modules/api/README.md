# Módulo API

Este módulo define la infraestructura necesaria para exponer un HTTP API Gateway que interactúa con la Lambda de `Upload`.

## Propósito
Crear el `aws_apigatewayv2_api` (HTTP), definir la integración Lambda Proxy (`payload_format_version = 2.0`), el stage por defecto auto-desplegable, permisos para invocar a Lambda y sus respectivos logs de acceso en CloudWatch.

## Variables

| Nombre | Descripción |
| ------ | ----------- |
| `environment` | Entorno de despliegue (dev, qa, prod) |
| `name_prefix` | Prefijo para los recursos |
| `upload_function_arn` | ARN de la función Lambda para dar permisos de invocación |
| `upload_invoke_arn` | ARN de la invocación de la Lambda para configurar la integración Proxy |

## Outputs

| Nombre | Descripción |
| ------ | ----------- |
| `api_endpoint` | URL base del API |
| `upload_url` | Ruta completa a `POST /upload` |
| `api_id` | Identificador del API |
| `api_access_log_group_name` | Nombre del Log Group de CloudWatch configurado con retención de 14 días |

## Riesgos y Consideraciones
*   La Lambda debe respetar el formato de salida `2.0` de API Gateway, o devolverá `502 Bad Gateway`.
*   API Gateway permite payloads de hasta 10MB, sin embargo la ejecución síncrona de Lambda tiene un límite de 6MB. Imágenes mayores fallarán.
*   El Throttling configurado (10,000 rps) está sujeto a las cuotas de la cuenta de AWS donde se despliegue.
