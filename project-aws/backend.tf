terraform {
  backend "s3" {
    # REMPLACEZ par le nom exact de votre bucket S3 créé pour l'état
    bucket = "gleo-tfstate-bucket-projet1-unique-12345"
    key    = "project-aws/terraform.tfstate" # Chemin du fichier d'état dans le bucket pour ce projet
    region = "eu-west-3"                          # Région de votre backend
    use_lockfile = true
    workspace_key_prefix = "env-"
    encrypt      = true
    //dynamodb_table       = "terraform-lock-table-projet1"

  }
}