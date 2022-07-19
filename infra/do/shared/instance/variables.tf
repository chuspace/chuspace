variable "name" {
  description = "Used to name various infrastructure components"
  default     = "chuspace-server"
}

variable "region" {
  description = "The DO region to deploy to"
  default     = "nyc1"
}

variable "image" {
  description = "The OS image to deploy"
  default     = "ubuntu-20-04-x64"
}

variable "instance_type" {
  description = "The size of the droplet."
  default     = "s-1vcpu-2gb-intel"
}

variable "server_count" {
  description = "The number of instances."
  default     = 2
}

variable "do_token" {
  description = "The DO token"
}

variable "weave_cloud_token" {
  description = "Weave cloud token for observability"
}

variable "docker_access_token" {
  description = "Docker access token"
}

variable "aws_access_key_id" {
  description = "Aws access key id for fetching secrets"
}

variable "aws_secret_access_key" {
  description = "Aws access key secret for fetching secrets"
}

variable "aws_region" {
  description = "Aws region to fetch secrets from"
}

variable "aws_ssm_secret_key_name" {
  description = "Aws secret manager key name"
}


