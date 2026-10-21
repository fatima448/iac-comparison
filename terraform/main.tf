
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.2.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "nginx" {
  name         = "nginx:1.27.5-alpine"
  keep_locally = true
}

resource "docker_network" "iac_lab" {
  name = "iac-lab-net"
}

resource "docker_container" "web" {
  name  = "iac-lab-web"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.iac_lab.name
  }

  ports {
    internal = 80
    external = 8080
    ip       = "127.0.0.1"
  }

  volumes {
    host_path      = abspath("${path.module}/../site/index.html")
    container_path = "/usr/share/nginx/html/index.html"
    read_only      = true
  }
}
