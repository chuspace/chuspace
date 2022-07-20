variable "region" {
  description = "Region to deploy to"
  default     = "eu-west-1"
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
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

