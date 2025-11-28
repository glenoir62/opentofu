config {
  # Formatte la sortie en JSON (optionnel, utile pour l'intégration machine)
  # format = "json"
  # Vous pouvez forcer tflint à échouer sur les avertissements (par défaut, il n'échoue que sur les erreurs)
  # force = true # Décommentez pour faire échouer le build sur les warnings
}

# Active le ruleset AWS (ensemble de règles spécifiques à AWS)
plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Exemple de configuration d'une règle spécifique (désactiver une règle)
# rule "aws_instance_invalid_type" {
#   enabled = false # Pour désactiver une règle spécifique si elle génère un faux positif pour vous
# }

# Exemple pour forcer certains tags (nécessite une configuration plus avancée ou un plugin de tag)
# Voir la documentation de tflint et des plugins pour des règles personnalisées.