data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region // Utilisation de la variable
  //Il faut retirer le profile car Github Actions utilisera son profil et ses identifiants OIDC :
  //profile = "projet1-sso"
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "dev-only-token"
}

/*
Detailed explanations on VPC creation
If you want to master VPCs, follow the AWS training, but here are some detailed explanations to help you understand what we're doing.
The cidr variable defines the IP address space of the VPC. This block then allocates six subnets (three public and three private),
each in a different availability zone of the region. This distribution promotes high availability: if one zone fails, the others can continue to operate. Public subnets are generally used for instances exposed to the Internet (like web servers), while private ones host databases or protected internal services.
Enabling the nat_gateway (with enable_nat_gateway = true)
allows private instances to connect to the Internet without being exposed.
This is essential for downloading packages or updating servers, while ensuring optimal network security.
 The single_nat_gateway = true directive allows using only one nat_gateway, reducing costs, even though this introduces a single point of failure in this case. In critical environments, you would prefer multiple nat_gateways, one per zone.
The DNS options (enable_dns_support and enable_dns_hostnames) enable DNS name resolution within the VPC and allow EC2 instances to have a DNS name associated with their private IP (and public if applicable).
These options are recommended for all VPCs, as many AWS services and system scripts use name resolution.
 Without this, features like yum or curl to internal services could fail.
Finally, the module accepts a tags block, which automatically applies tags to all created resources.

This facilitates project management, sorting in the AWS console, and especially cost analysis via AWS Billing.Claude peut faire des erreurs. Assurez-vous de vérifier ses réponses.
 */
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # Consultez le Terraform Registry pour la dernière version stable et compatible (ex: ~> 5.0)
  version = "~> 5.5.0" # IMPORTANT: Spécifiez et vérifiez la version !

  name = "${var.project_name}-VPC"
  cidr = var.vpc_cidr_block # Utilise la variable définie dans variables.tf racine

  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs" # Ou "s3"
  flow_log_traffic_type                = "ALL"

  # Pour une configuration simple avec CloudWatch Logs, vous devrez créer
  # un groupe CloudWatch Log et un rôle IAM avec les permissions nécessaires.
  # Le module VPC peut créer le groupe de logs pour vous si vous lui donnez un nom :
  //flow_log_cloudwatch_log_group_name = "/aws/vpc/${var.project_name}-${terraform.workspace}-flow-logs"
  # Pour le rôle IAM, le module peut aussi le créer si vous activez create_flow_log_cloudwatch_iam_role = true
  # Pour la simplicité ici, nous allons laisser le module tenter de le créer :
  create_flow_log_cloudwatch_iam_role = true
  create_flow_log_cloudwatch_log_group = true


  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"] # Exemple pour 3 AZs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]                      # Exemple de CIDRs pour sous-réseaux privés
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]                # Exemple de CIDRs pour sous-réseaux publics

  enable_nat_gateway = true # Crée une NAT Gateway pour les sous-réseaux privés (peut engendrer des coûts)
  single_nat_gateway = true # Utilise une seule NAT Gateway pour toutes les AZs (réduit les coûts)

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    ManagedBy = "Terraform"
    Environment = var.environment_tag
    Project     = var.project_name
  }
}

# Appel de notre module local 'instance_web'
module "serveur_web_1" {
  source = "./modules/instance_web" # Chemin vers notre module

  ami_id          = data.aws_ami.amazon_linux_2023.id
  instance_type   = var.instance_type # Utilise la variable définie dans le variables.tf racine
  project_name    = var.project_name
  environment_tag = var.environment_tag
  subnet_id       = module.vpc.public_subnets[0] # Utilise le premier sous-réseau public du module VPC
  vpc_id          = module.vpc.vpc_id            # Utilise l'ID du VPC créé par le module VPC
  //secret_tag_value_sm = local.app_api_key_from_sm
}

# Vous pourriez même appeler le module une seconde fois pour créer un autre serveur !
# module "serveur_web_2" {
#   source = "./modules/instance_web"
#
#   ami_id        = data.aws_ami.amazon_linux_2023.id
#   instance_type = "t3.small" # Type différent
#   project_name  = var.project_name
#   environment_tag = "Staging" # Environnement différent
# }

# data "aws_secretsmanager_secret_version" "app_api_key_secret" {
#   secret_id = "projet1/app/api_key" // REMPLACEZ si vous avez utilisé un autre nom
# }

data "vault_kv_secret_v2" "app_db_credentials" {
  mount = "secret"
  name  = "projet1/app/database"
}