## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_serveur_web_1"></a> [serveur\_web\_1](#module\_serveur\_web\_1) | ./modules/instance_web | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.tfstate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.tfstate_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.tfstate_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.tfstate_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_ami.amazon_linux_2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | La région AWS où les ressources seront déployées. | `string` | `"eu-west-3"` | no |
| <a name="input_environment_tag"></a> [environment\_tag](#input\_environment\_tag) | Tag d'environnement (ex: Development, Staging, Production). | `string` | `"Development"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Le type d'instance EC2 à utiliser pour le serveur web. | `string` | `"t2.micro"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet, utilisé pour le taggage des ressources. | `string` | `"Projet1-IaC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_server_instance_id"></a> [web\_server\_instance\_id](#output\_web\_server\_instance\_id) | ID de l'instance EC2 NGINX. |
| <a name="output_web_server_public_ip"></a> [web\_server\_public\_ip](#output\_web\_server\_public\_ip) | Adresse IP publique de l'instance EC2 NGINX. |

## VAULT

```
docker run -d --cap-add=IPC_LOCK -p 8200:8200 -e 'VAULT_DEV_ROOT_TOKEN_ID=dev-only-token' hashicorp/vault server -dev

Adresse de Vault (VAULT_ADDR) : http://127.0.0.1:8200

Token Racine (VAULT_TOKEN) : dev-only-token

export VAULT_ADDR='http://127.0.0.1:8200'
vault login dev-only-token
vault kv put secret/projet1/app/database username="app_user_vault" password="SuperSecretPasswordFromVault123!"
vault kv get secret/projet1/app/database

```
## TEST

```
go mod init dyma-iac/test

go get github.com/gruntwork-io/terratest/modules/terraform
go get github.com/gruntwork-io/terratest/modules/aws
go get github.com/gruntwork-io/terratest/modules/http-helper
go get github.com/stretchr/testify/assert

go mod tidy

aws sso login --profile XXXX
export AWS_PROFILE=XXXXX

from instance_web_module_test path
go test -v -timeout 30m
```