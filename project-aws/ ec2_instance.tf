resource "aws_instance" "web_server" {
  # Exemple pour Amazon Linux 2023 (à vérifier/remplacer) : recherchez la dernière AL2023
  ami           = "ami-074e262099d145e90"
  instance_type = "t2.micro" # Type d'instance éligible au niveau gratuit (vérifiez les conditions)

  # Configuration des métadonnées pour IMDSv2 (recommandé)
  metadata_options {
    http_tokens   = "required" # Force l'utilisation de tokens pour IMDSv2
    http_endpoint = "enabled"
  }

  # Associer le groupe de sécurité créé précédemment
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Script exécuté au premier démarrage de l'instance
  user_data = <<-EOF
            #!/bin/bash
            # Mettre à jour les paquets
            dnf update -y
            # Installer NGINX
            dnf install nginx -y
            # Démarrer le service NGINX
            systemctl start nginx
            # Activer le service NGINX pour qu'il démarre automatiquement au boot
            systemctl enable nginx

            # Obtenir un token pour IMDSv2
            TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

            # Récupérer les métadonnées de l'instance en utilisant le token IMDSv2
            INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
            INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-type)
            AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
            PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
            PRIVATE_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

            # Le répertoire racine par défaut pour NGINX sur Amazon Linux est /usr/share/nginx/html/
            cat <<EOT > /usr/share/nginx/html/index.html
            <html lang="fr">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Infos Instance EC2 (NGINX)</title>
                <style>
                  body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f8ff; color: #333; }
                  h1 { color: #2072a9; } /* Couleur NGINX-like */
                  table { border-collapse: collapse; width: 60%; margin-top: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
                  th, td { text-align: left; padding: 14px; border-bottom: 1px solid #cce5ff; }
                  th { background-color: #2072a9; color: white; }
                  tr:nth-child(even) { background-color: #e7f3fe; }
                  tr:hover { background-color: #d1e7fd; }
                </style>
              </head>
              <body>
                <h1>Informations sur cette Instance EC2 (Servi par NGINX)</h1>
                <table>
                  <tr><th>Attribut</th><th>Valeur</th></tr>
                  <tr><td>ID de l'Instance</td><td>$INSTANCE_ID</td></tr>
                  <tr><td>Type d'Instance</td><td>$INSTANCE_TYPE</td></tr>
                  <tr><td>Zone de Disponibilité</td><td>$AVAILABILITY_ZONE</td></tr>
                  <tr><td>IP Publique IPv4</td><td>$PUBLIC_IPV4</td></tr>
                  <tr><td>IP Privée IPv4</td><td>$PRIVATE_IPV4</td></tr>
                </table>
              </body>
            </html>
            EOT
            EOF

  tags = {
    Name        = "WebServer-NGINX-Metadata-Projet1"
    Environment = "Development"
    ManagedBy   = "Terraform" // ou "OpenTofu"
    Project     = "Projet1-IaC"
  }
}

output "web_server_public_ip" {
  description = "Adresse IP publique de l'instance EC2 NGINX. Accédez via http://<IP_PUBLIQUE>"
  value       = aws_instance.web_server.public_ip
}

output "web_server_instance_id" {
  description = "ID de l'instance EC2 NGINX."
  value       = aws_instance.web_server.id
}