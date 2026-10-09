# Módulo Observability

Este módulo se encarga de aprovisionar los recursos de monitoreo y alertas.

## Propósito
Configura una alarma en CloudWatch que vigila la métrica `ApproximateNumberOfMessagesVisible` de la cola de correos muertos (DLQ) de SQS. Si entra algún mensaje a la DLQ, dispara una alarma hacia un SNS Topic.

## Variables

| Nombre | Descripción |
| ------ | ----------- |
| `environment` | Entorno de despliegue |
| `name_prefix` | Prefijo para los recursos |
| `dlq_queue_name` | Nombre de la DLQ a monitorear |

## Outputs

| Nombre | Descripción |
| ------ | ----------- |
| `sns_topic_arn` | ARN del tópico SNS creado |
| `dlq_alarm_name` | Nombre de la alarma en CloudWatch |

## Consideraciones
*   La alarma tiene un periodo de evaluación de 60 segundos.
*   No se ha incluido suscripción por email (`aws_sns_topic_subscription`) por defecto ya que requiere confirmación manual, lo cual bloquea automatizaciones en despliegues efímeros. Quien consuma este topic debe suscribirse posteriormente o inyectar su suscripción.
