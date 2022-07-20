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

variable "logtail_token" {
  description = "Logtail token for observability"
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

