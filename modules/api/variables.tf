variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
}

variable "name_prefix" {
  description = "Prefijo para nombrar los recursos"
  type        = string
}
