variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
}

variable "name_prefix" {
  description = "Prefijo para nombrar los recursos"
  type        = string
}

variable "upload_invoke_arn" {
  description = "ARN de invocacion de la funcion Lambda Upload para API Gateway"
  type        = string
}
