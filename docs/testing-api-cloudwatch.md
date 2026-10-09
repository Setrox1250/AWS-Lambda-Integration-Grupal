# Pruebas del Pipeline y Observabilidad

Este documento describe el proceso para validar la infraestructura del API Gateway, CloudWatch y el pipeline de subida de imágenes.

## 1. Prueba Smoke Test de API y Flujo E2E

El script provisto comprueba la accesibilidad del API (Smoke Test). Para validar el flujo E2E completo, se debe verificar también el resultado final en S3.

```bash
chmod +x scripts/test-upload.sh
./scripts/test-upload.sh "$(terraform -chdir=envs/dev output -raw upload_url)" ./testdata/foto.png
```

### Flujo esperado:
1. El script enviará el archivo a través del **API Gateway** (HTTP POST).
2. El API invocará de forma **síncrona** la Lambda `Upload` (AWS_PROXY con payload 2.0).
3. `Upload` guardará la imagen en S3 (`uploads/`).
4. S3 enviará un evento asíncrono a SQS.
5. SQS disparará la Lambda `Crop`.
6. **[Verificación requerida]** Se debe acceder a S3 y validar que exista una imagen circular de 40x40 en el prefijo `processed/`.

## 2. Evidencias de CloudWatch (API)

Para verificar el registro de accesos:
1. Ingresar a **CloudWatch** -> **Log groups**.
2. Buscar: `/aws/apigateway/image-processor-<entorno>`.
3. Validar el log stream con el JSON de la petición HTTP.

## 3. Evidencias de Observabilidad (DLQ y SNS)

1. Forzar un fallo en la Lambda `Crop` (ej. subir un archivo no válido).
2. Esperar a que el mensaje pase a la DLQ.
3. Verificar en **CloudWatch Alarms** que `<prefix>-dlq-messages` pase a **In alarm** (umbral 0, 60s).
4. Validar en **SNS** la notificación. (Nota: Si se definió un `alert_email`, confirmar recepción en la bandeja de entrada tras haber aceptado la suscripción).
