# ─────────────────────────────────────────────────────────────────────────────
# modules/network/outputs.tf
# Consumidos por el root envs/{dev,qa,prod}/main.tf
# ─────────────────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs de las dos subnets públicas [az-a, az-b]"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "IDs de las dos subnets privadas [az-a, az-b]. Usadas por las Lambdas."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "sg_upload_lambda_id" {
  description = "ID del Security Group de la Upload Lambda (sin ingress)"
  value       = aws_security_group.upload_lambda.id
}

output "sg_crop_lambda_id" {
  description = "ID del Security Group de la Crop Lambda (sin ingress)"
  value       = aws_security_group.crop_lambda.id
}

output "s3_endpoint_id" {
  description = "ID del VPC Gateway Endpoint para S3"
  value       = aws_vpc_endpoint.s3.id
}

output "sqs_endpoint_id" {
  description = "ID del VPC Interface Endpoint para SQS"
  value       = aws_vpc_endpoint.sqs.id
}

output "nat_gateway_ids" {
  description = "IDs de los dos NAT Gateways [nat-a, nat-b]"
  value       = [aws_nat_gateway.a.id, aws_nat_gateway.b.id]
}

output "eip_allocation_ids" {
  description = "IDs de asignación de las dos Elastic IPs [eip-nat-a, eip-nat-b]"
  value       = [aws_eip.nat_a.id, aws_eip.nat_b.id]
}

output "private_route_table_ids" {
  description = "IDs de las route tables privadas [rt-private-a, rt-private-b]. Necesarias para asociar el S3 Gateway Endpoint."
  value       = [aws_route_table.private_a.id, aws_route_table.private_b.id]
}

# Outputs informativos adicionales
output "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "Zonas de disponibilidad usadas [az-a, az-b]"
  value       = [local.az_a, local.az_b]
}
