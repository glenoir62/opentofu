# Fichier: setup/s3.tf (ou un nouveau fichier logging.tf dans setup/)

# Bucket pour stocker les logs du bucket tfstate (doit être dans la même région)
resource "aws_s3_bucket" "tfstate_logs" {
  bucket = "${aws_s3_bucket.tfstate.bucket}-logs" # Assurez-vous que ce nom est unique

  tags = {
    Name        = "Terraform State Logs Bucket - Projet1"
    Environment = "Backend-Logs"
    ManagedBy   = "Terraform"
  }
}

# Empêcher la suppression accidentelle du bucket de logs s'il contient des objets
resource "aws_s3_bucket_lifecycle_configuration" "tfstate_logs_lifecycle" {
  bucket = aws_s3_bucket.tfstate_logs.id
  rule {
    id     = "prevent_delete"
    status = "Enabled"
  }
}

# Activer la journalisation sur le bucket tfstate
resource "aws_s3_bucket_logging" "tfstate_logging" {
  bucket = aws_s3_bucket.tfstate.id

  target_bucket = aws_s3_bucket.tfstate_logs.id
  target_prefix = "log/"
}
