data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "aws_account_id" {
  description = "Cuenta AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Region AWS"
  value       = data.aws_region.current.name
}

output "api_endpoint" {
  description = "API Endpoint"
  value       = module.api.api_endpoint
}

output "upload_url" {
  description = "Upload URL"
  value       = module.api.upload_url
}

output "bucket_id" {
  description = "Bucket S3"
  value       = module.storage.bucket_id
}

output "main_queue_arn" {
  description = "ARN Cola SQS Principal"
  value       = module.storage.main_queue_arn
}

output "dlq_arn" {
  description = "ARN Cola SQS DLQ"
  value       = module.storage.dlq_arn
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.network.vpc_id
}

output "upload_lambda_name" {
  description = "Upload Lambda Name"
  value       = module.compute.upload_function_name
}

output "crop_lambda_name" {
  description = "Crop Lambda Name"
  value       = module.compute.crop_function_name
}

output "nat_gateway_ids" {
  description = "IDs de NAT Gateways"
  value       = module.network.nat_gateway_ids
}
