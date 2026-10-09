output "api_endpoint" {
  description = "URL base del API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "upload_url" {
  description = "URL completa para realizar el POST de la imagen"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/upload"
}

output "api_id" {
  description = "ID del API Gateway generado"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_access_log_group_name" {
  description = "Nombre del CloudWatch Log Group del API"
  value       = aws_cloudwatch_log_group.api_logs.name
}
