# ─────────────────────────────────────────────────────────────────────────────
# modules/network/endpoints.tf
# VPC Endpoints del Mermaid:
#   - S3 Gateway Endpoint (gratuito, sin ENI, inyectado en route tables privadas)
#   - SQS Interface Endpoint (ENI en priv-a y priv-b, private DNS habilitado)
#
# Nota sobre locals: az_a y az_b se definen en vpc.tf y se comparten automáticamente
# Terraform fusiona todos los bloques locals del módulo
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # Política del S3 Gateway Endpoint
  # Si se recibe el ARN del bucket (desde module.storage en el root)
  # se restringe a GetObject/PutObject sobre ese bucket únicamente
  # Si no se pasa ARN (bootstrap), se omite la policy y AWS aplica la default
  s3_endpoint_policy = var.bucket_arn != "" ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowImagesBucketOnly"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${var.bucket_arn}",
          "${var.bucket_arn}/*"
        ]
      }
    ]
  }) : null
}

# S3 Gateway Endpoint
# Tipo: Gateway gratuito, sin ENI, se inyecta en las route tables indicadas
# Se asocia solo a las route tables privadas

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id,
  ]

  policy = local.s3_endpoint_policy

  tags = {
    Name = "${var.name_prefix}-vpce-s3"
  }
}

# SQS Interface Endpoint
# Tipo: Interface crea una ENI por AZ en las subnets privadas indicadas
# private_dns_enabled = true: sqs.us-east-1.amazonaws.com resuelve internamente
# Nota: el Event Source Mapping de Lambda usa SQS como servicio administrado
# este endpoint garantiza que el tráfico permanezca en el backbone de AWS

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  security_group_ids = [
    aws_security_group.vpce_sqs.id,
  ]

  tags = {
    Name = "${var.name_prefix}-vpce-sqs"
  }
}
