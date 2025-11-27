resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock-table-projet1"
  billing_mode = "PAY_PER_REQUEST"  # Pas de frais fixes, tu paies à l'usage
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}
