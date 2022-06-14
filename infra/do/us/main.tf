terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.20.0"
    }
  }
}

module "us_nyc_servers" {
  source = "../server"

  region = "nyc1"
  name   = "chuspace-app"
  do_token             = var.do_token
  instance_type        = "s-1vcpu-2gb-intel"
  server_count         = 2
}

module "us_sfo_servers" {
  source = "../server"

  region = "sfo3"
  name   = "chuspace-app"

  do_token             = var.do_token
  instance_type        = "s-1vcpu-2gb-intel"
  server_count         = 2
}

module "us_tor_servers" {
  source = "../server"

  region = "tor1"
  name   = "chuspace-app"

  do_token             = var.do_token
  instance_type        = "s-1vcpu-2gb-intel"
  server_count         = 2
}
