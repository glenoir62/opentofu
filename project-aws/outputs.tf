output "s3_bucket_name" {
  description = "Nom du bucket S3 créé pour le backend Terraform."
  value       = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  description = "Nom de la table DynamoDB créée pour le verrouillage de l'état Terraform."
  value       = aws_dynamodb_table.terraform_locks.name
}