variable "ami_id" {
  description = "L'ID de l'AMI à utiliser pour l'instance EC2."
  type        = string
}

variable "instance_type" {
  description = "Le type d'instance EC2."
  type        = string
  default     = "t2.micro"
}

variable "instance_type_prod" {
  type    = string
  default = "t3.small"
}

variable "instance_type_dev" {
  type    = string
  default = "t2.micro"
}

variable "project_name" {
  description = "Nom du projet pour les tags."
  type        = string
}

variable "environment_tag" {
  description = "Tag d'environnement."
  type        = string
}

variable "subnet_id" {
  description = "L'ID du sous-réseau dans lequel lancer l'instance EC2."
  type        = string
}

variable "vpc_id" {
  description = "L'ID du VPC pour le groupe de sécurité de l'instance."
  type        = string
}

# variable "secret_tag_value_sm" {
#   description = "Valeur secrète de SM pour un tag de démonstration."
#   type        = string
#   sensitive   = true
# }