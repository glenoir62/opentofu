# resource "local_file" "index" {
#   filename = "${path.module}/index.html"
#   content  = "<html><body><h1>Bienvenue GLEO</h1></body></html>"
# }
#
# resource "local_file" "texte" {
#   filename = "${path.module}/exemple.txt"
#   content  = "Contenu généré automatiquement."
# }

# Lecture d'un fichier HTML local existant
data "local_file" "html" {
  filename = abspath("${path.module}/index.html")
}

resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}
resource "null_resource" "generate_config" {
  provisioner "local-exec" {
    command = "echo 'config' > config.json"
  }
}
resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "web-nginx"
  ports {
    internal = 80
    external = var.container_port
  }
  volumes {
    host_path      = data.local_file.html.filename
    container_path = "/usr/share/nginx/html/index.html"
  }
  // tofu graph
  //Ici, le conteneur sera lancé uniquement après l’exécution du script local-exec.
  // Même si le conteneur ne dépend pas directement du fichier config.json,
  // la dépendance est déclarée explicitement.
  depends_on = [null_resource.generate_config, data.local_file.html]
  # mounts {
  #   target = "/usr/share/nginx/html/index.html"
  #   source = abspath(local_file.index.filename)
  #   type   = "bind"
  # }tofu graph
}

