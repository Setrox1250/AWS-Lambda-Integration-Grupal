output "bucket_id" {
  description = "Nombre del bucket S3."
  value       = aws_s3_bucket.images.id
}

output "bucket_arn" {
  description = "ARN del bucket S3."
  value       = aws_s3_bucket.images.arn
}

output "uploads_prefix" {
  description = "Prefijo de imagenes originales."
  value       = local.uploads_prefix
}

output "processed_prefix" {
  description = "Prefijo de imagenes procesadas."
  value       = local.processed_prefix
}

output "main_queue_arn" {
  description = "ARN de la cola principal."
  value       = aws_sqs_queue.main.arn
}

output "main_queue_url" {
  description = "URL de la cola principal."
  value       = aws_sqs_queue.main.url
}

output "main_queue_name" {
  description = "Nombre de la cola principal."
  value       = aws_sqs_queue.main.name
}

output "dlq_arn" {
  description = "ARN de la DLQ."
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "Nombre de la DLQ (lo usa la alarma de observability)."
  value       = aws_sqs_queue.dlq.name
}