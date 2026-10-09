output "upload_function_arn" {
  description = "ARN de la Lambda Upload."
  value       = aws_lambda_function.upload.arn
}

output "upload_invoke_arn" {
  description = "Invoke ARN de la Lambda Upload (para API Gateway)."
  value       = aws_lambda_function.upload.invoke_arn
}

output "upload_function_name" {
  description = "Nombre de la Lambda Upload."
  value       = aws_lambda_function.upload.function_name
}

output "crop_function_arn" {
  description = "ARN de la Lambda Crop."
  value       = aws_lambda_function.crop.arn
}

output "crop_function_name" {
  description = "Nombre de la Lambda Crop."
  value       = aws_lambda_function.crop.function_name
}

output "upload_log_group_name" {
  description = "Log Group de Upload."
  value       = aws_cloudwatch_log_group.upload.name
}

output "crop_log_group_name" {
  description = "Log Group de Crop."
  value       = aws_cloudwatch_log_group.crop.name
}