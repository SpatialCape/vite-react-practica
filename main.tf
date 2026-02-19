provider "aws" {
  region = "us-east-1"
}

variable "github_token" {
  description = "Token de acceso personal de GitHub"
  type        = string
  sensitive   = true
}

resource "aws_amplify_app" "hola_mundo" {
  name       = "vite-react-practica"
  # 1. Actualizado con la URL de tu nuevo repositorio
  repository = "https://github.com/SpatialCape/vite-react-practica.git"
  
  # 2. Cambiado de oauth_token a access_token (oauth_token está deprecado en AWS provider)
  access_token = var.github_token

  build_spec = <<-EOT
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
EOT

  custom_rule {
    source = "</^((?!\\.).)*$/>"
    target = "/index.html"
    status = "200"
  }
}

# 3. Cambiamos el nombre del recurso y la rama a "main"
resource "aws_amplify_branch" "main" {
  app_id            = aws_amplify_app.hola_mundo.id
  branch_name       = "main"
  # 4. Habilitamos la construcción automática para cumplir con el Paso 8
  enable_auto_build = true 
}

# Añadimos un output para que la terminal te regrese la URL de tu app al terminar
output "amplify_app_url" {
  value = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.hola_mundo.default_domain}"
}