variable "environment" {
  description = "Entorno de despliegue"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment debe ser dev, qa o prod."
  }
}

variable "name_prefix" {
  description = "Prefijo de nombres, ej. image-processor-dev."
  type        = string
}

variable "force_destroy" {
  description = "Permite destruir el bucket con objetos y versiones. SOLO para tarea efimera."
  type        = bool
  default     = true
}