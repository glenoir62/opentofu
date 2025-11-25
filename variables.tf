variable "container_port" {
  type        = number
  default     = 8000
  description = "Port exposé sur la machine hôte"
}


variable "nom_serveur" {
  type    = string
  default = "web-01"
}

variable "zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "images" {
  type = map(string)
  default = {
    "ubuntu" = "ami-123456",
    "centos" = "ami-789012"
  }
}

variable "tags" {
  type    = set(string)
  default = ["web", "production", "secure"]
}

variable "utilisateur" {
  type = object({
    nom     = string
    actif   = bool
    niveau  = number
  })
}

variable "coordonnees" {
  type    = tuple([number, number])
  default = [48.8584, 2.2945]
}
