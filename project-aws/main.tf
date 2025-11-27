terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Vous pouvez ajuster la version selon vos besoins
    }
  }
}

provider "aws" {
  region  = "eu-west-3" # Région où les ressources du backend seront créées
  profile = "projet1-sso"
}