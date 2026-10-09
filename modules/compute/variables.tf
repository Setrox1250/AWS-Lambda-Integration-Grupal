variable "environment" {
  description = "Entorno de despliegue (dev, qa o prod)."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment debe ser dev, qa o prod."
  }
}

variable "name_prefix" {
  description = "Prefijo de nombres, p. ej. image-processor-dev."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las dos subnets privadas (A y B) donde se asocian ambas Lambdas."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) == 2
    error_message = "Se requieren exactamente 2 subnets privadas."
  }
}

variable "upload_lambda_sg_id" {
  description = "Security Group de la Lambda Upload."
  type        = string
}

variable "crop_lambda_sg_id" {
  description = "Security Group de la Lambda Crop."
  type        = string
}

variable "bucket_id" {
  description = "Nombre del bucket S3 (uploads/ y processed/)."
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket S3."
  type        = string
}

variable "main_queue_arn" {
  description = "ARN de la cola SQS principal que dispara Crop."
  type        = string
}

variable "upload_zip_path" {
  description = "Ruta al ZIP de la Lambda Upload. Requerido en apply; omitir en validate."
  type        = string
  default     = null
}

variable "crop_zip_path" {
  description = "Ruta al ZIP de la Lambda Crop. Requerido en apply; omitir en validate."
  type        = string
  default     = null
}

variable "runtime" {
  description = "Runtime de ambas Lambdas. nodejs20.x segun el Mermaid; documentar si hay que pasar a nodejs22.x."
  type        = string
  default     = "nodejs20.x"
}

variable "log_retention_days" {
  description = "Retencion de los Log Groups de Lambda."
  type        = number
  default     = 14
}