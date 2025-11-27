resource "aws_security_group" "web_sg" {
  name        = "web-sg-projet1-nginx"
  description = "Allow HTTP inbound traffic for Projet1 NGINX WebServer"

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Autorise le trafic HTTP depuis n'importe quelle IP
    ipv6_cidr_blocks = ["::/0"]     # Autorise le trafic HTTP depuis n'importe quelle IP (IPv6)
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # "-1" signifie tous les protocoles
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "WebServer-NGINX-SG-Projet1"
    Project   = "Projet1-IaC"
    ManagedBy = "Terraform"
  }
}

output "web_security_group_id" {
  description = "ID du groupe de sécurité pour le serveur web NGINX."
  value       = aws_security_group.web_sg.id
}