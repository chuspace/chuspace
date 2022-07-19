variable "region" {
  description = "Region to deploy to"
  default     = "sgp1"
}

variable "do_token" {
  description = "DO personal access token"
}

variable "server_count" {
  description = "Number of instances"
  default     = 2
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

variable "docker_swarm_token" {
  description = "Docker swarm token"
}

variable "docker_swarm_address" {
  description = "Docker swarm address"
}

