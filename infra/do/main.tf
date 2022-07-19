terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.20.0"
    }
  }
}

module "do_instance" {
  source = "./shared/instance"

  region               = "${var.region}"
  name                 = "chuspace-docker-app"
  do_token             = var.do_token
  instance_type        = "s-1vcpu-2gb-intel"
  server_count         = var.server_count

  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = var.aws_region
  aws_ssm_secret_key_name   = var.aws_ssm_secret_key_name
}
