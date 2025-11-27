/*
tofu destroy -target=aws_instance.web_server
export AWS_PROFILE=
tofu apply -replace=aws_instance.web_server

aws ec2 get-console-output --instance-id web_server_instance_id --profile projet1-sso


Ce bloc data "aws_ami" "amazon_linux_2023" permet à Terraform de rechercher automatiquement l’image Amazon Machine Image (AMI)
 la plus récente correspondant à Amazon Linux 2023.
  Il utilise le champ most_recent = true pour ne sélectionner qu’une seule image, publiée par Amazon (owners = ["amazon"]).
 */data "aws_ami" "amazon_linux_2023" {
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

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # User data corrigé pour Amazon Linux 2023
  user_data = <<-EOF
            #!/bin/bash
            # Log tout dans un fichier pour debugging
            exec > >(tee /var/log/user-data.log)
            exec 2>&1

            echo "=== Début du script user-data ==="
            date

            # Mise à jour du système
            echo "Mise à jour du système..."
            dnf update -y

            # Installation de Nginx (AL2023 utilise dnf, pas amazon-linux-extras)
            echo "Installation de Nginx..."
            dnf install -y nginx

            # Démarrage et activation de Nginx
            echo "Démarrage de Nginx..."
            systemctl start nginx
            systemctl enable nginx
            systemctl status nginx

            # Récupération des métadonnées
            echo "Récupération des métadonnées..."
            TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

            INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
            INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-type)
            AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
            PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
            PRIVATE_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

            # Création de la page HTML
            echo "Création de la page HTML..."
            cat <<EOT > /usr/share/nginx/html/index.html
            <!DOCTYPE html>
            <html lang="fr">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Infos Instance EC2 (NGINX) - ${var.environment_tag}</title>
                <style>
                  body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f8ff; color: #333; }
                  h1 { color: #2072a9; }
                  table { border-collapse: collapse; width: 60%; margin-top: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
                  th, td { text-align: left; padding: 14px; border-bottom: 1px solid #cce5ff; }
                  th { background-color: #2072a9; color: white; }
                  tr:nth-child(even) { background-color: #e7f3fe; }
                  tr:hover { background-color: #d1e7fd; }
                </style>
              </head>
              <body>
                <h1>🚀 Serveur Web NGINX - Environnement: ${var.environment_tag}</h1>
                <table>
                  <tr><th>Attribut</th><th>Valeur</th></tr>
                  <tr><td>ID de l'Instance</td><td>$INSTANCE_ID</td></tr>
                  <tr><td>Type d'Instance</td><td>$INSTANCE_TYPE</td></tr>
                  <tr><td>Zone de Disponibilité</td><td>$AVAILABILITY_ZONE</td></tr>
                  <tr><td>IP Publique IPv4</td><td>$PUBLIC_IPV4</td></tr>
                  <tr><td>IP Privée IPv4</td><td>$PRIVATE_IPV4</td></tr>
                </table>
                <p style="margin-top: 20px; color: #666;">
                  <small>Instance démarrée le $(date) | Géré par OpenTofu</small>
                </p>
              </body>
            </html>
            EOT

            # Redémarrage de Nginx pour être sûr
            echo "Redémarrage de Nginx..."
            systemctl restart nginx

            echo "=== Fin du script user-data ==="
            date
            EOF

  tags = {
    Name        = "WebServer-NGINX-${var.project_name}"
    Environment = var.environment_tag
    ManagedBy   = "OpenTofu"
    Project     = var.project_name
  }
}

output "web_server_public_ip" {
  description = "Adresse IP publique de l'instance EC2 NGINX"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "web_server_instance_id" {
  description = "ID de l'instance EC2 NGINX"
  value       = aws_instance.web_server.id
}
