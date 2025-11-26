variable "container_port" {
  type        = number
  default     = 8000
  description = "Port exposé sur la machine hôte"
}


variable "nom_serveur" {
  type    = string
  default = "web-01"
}

variable "roles" {
  type = map(string)
  default = {
    "user"          = "lecture-seule"
    "admin"         = "ecriture"
    "lecture-seule" = "lecture-seule"
  }
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
    nom    = string
    actif  = bool
    niveau = number
  })

  validation {
    //condition     = alltrue([for p in var.ports_autorises : p >= 1024 && p <= 65535])
    //condition     = can(regex("^[a-z]+$", var.nom_projet))
    //condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    //condition     = can(regex("^.+@.+$", var.email_contact))
    condition     = var.utilisateur.nom == "GLEO"
    error_message = "La variable validation_test doit être exactement 'ok'"
  }
}

variable "coordonnees" {
  type    = tuple([number, number])
  default = [48.8584, 2.2945]
}
