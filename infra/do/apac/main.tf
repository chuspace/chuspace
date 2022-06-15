terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.20.0"
    }
  }
}

module "apac_sgp_servers" {
  source = "../server"

  region = "sgp1"
  name   = "chuspace-app"
  do_token             = var.do_token
  instance_type        = "s-1vcpu-2gb-intel"
  server_count         = 2
}
