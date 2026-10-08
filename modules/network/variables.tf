# ─────────────────────────────────────────────────────────────────────────────
# modules/network/variables.tf
# Inputs del módulo de red, ningún valor default hard-coded de credenciales
# ─────────────────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Nombre del entorno: dev, qa o prod"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev', 'qa' o 'prod'."
  }
}

variable "name_prefix" {
  description = "Prefijo común para todos los recursos: 'image-processor-<environment>'"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC. Debe ser /16 para acomodar los cuatro /24 del Mermaid."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr debe ser un bloque CIDR válido (ej. 10.0.0.0/16)."
  }
}

variable "aws_region" {
  description = "Región AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "bucket_arn" {
  description = <<-EOT
    ARN del bucket S3 de imágenes. Se usa para restringir la política del
    Gateway Endpoint de S3. Se recibe desde module.storage en el root.
    Si se deja vacío se aplica una política permisiva (solo para bootstrap).
  EOT
  type        = string
  default     = ""
}
