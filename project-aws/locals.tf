locals {
  //app_api_key_from_sm = jsondecode(data.aws_secretsmanager_secret_version.app_api_key_secret.secret_string)["my_app_api_key"]


  # Configurations d'instance par environnement
  instance_configurations = {
    dev = {
      instance_type = "t2.micro" // Plus petit et moins cher pour dev
      # On pourrait ajouter d'autres paramètres spécifiques à dev ici
    }
    prod = {
      instance_type = "t3.small" // Un peu plus robuste pour prod
      # On pourrait ajouter d'autres paramètres spécifiques à prod ici
    }
    default = { # Au cas où un workspace non défini serait utilisé
      instance_type = "t2.micro"
    }
  }

  # Sélection de la configuration pour le workspace actuel
  current_instance_config = lookup(local.instance_configurations, terraform.workspace, local.instance_configurations.default)

  # Tags communs à toutes les ressources, avec l'environnement dynamiquement ajouté
  common_tags = {
    ManagedBy   = "Terraform"         // ou "OpenTofu"
    Project     = var.project_name    // Utilise la variable globale du projet
    Environment = terraform.workspace // Ajoute dynamiquement le nom du workspace
  }

  db_user_from_vault     = data.vault_kv_secret_v2.app_db_credentials.data["username"]
  db_password_from_vault = data.vault_kv_secret_v2.app_db_credentials.data["password"]

}

