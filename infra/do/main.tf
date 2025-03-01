terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.20.0"
    }
  }
}

module "do_instance" {
  source = "./shared/instance"

  region        = var.region
  name          = "chuspace-docker-app"
  do_token      = var.do_token
  instance_type = "s-1vcpu-2gb-intel"
  server_count  = var.server_count

  docker_access_token = var.docker_access_token
}
