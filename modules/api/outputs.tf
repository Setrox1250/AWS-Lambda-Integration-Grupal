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
