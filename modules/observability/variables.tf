variable "environment" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "dlq_queue_name" {
  type = string
}

variable "alert_email" {
  description = "Correo opcional para alertas SNS"
  type        = string
  default     = null
}
