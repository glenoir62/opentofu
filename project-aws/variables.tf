variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "projet1"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment doit être dev, staging ou prod."
  }
}

variable "utilisateur" {
  description = "Nom de l'utilisateur/propriétaire"
  type        = string
  default     = "gleo"
}
