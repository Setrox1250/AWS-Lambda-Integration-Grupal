variable "environment" {
  description = "Entorno"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "upload_zip_path" {
  description = "Ruta al ZIP de la Lambda Upload"
  type        = string
}

variable "crop_zip_path" {
  description = "Ruta al ZIP de la Lambda Crop"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "log_retention_days" {
  description = "Retencion de los Log Groups de Lambda"
  type        = number
  default     = 14
}
