variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
}

variable "name_prefix" {
  description = "Prefijo para nombrar los recursos"
  type        = string
}

variable "upload_function_arn" {
  description = "ARN de la funcion Lambda Upload"
  type        = string
}

variable "upload_invoke_arn" {
  description = "ARN de invocacion de la funcion Lambda Upload para API Gateway"
  type        = string
}
