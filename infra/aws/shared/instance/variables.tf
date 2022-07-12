variable "name" {
  description = "Used to name various infrastructure components"
  default     = "chuspace-docker-app"
}

variable "region" {
  description = "The AWS region to deploy to."
}

variable "vpc_id" {
  description = "The AWS vpc to deploy to."
}

variable "instance_type" {
  description = "The AWS instance type to use for servers."
  default     = "t3.small"
}

variable "root_block_device_size" {
  description = "The volume size of the root block device."
  default     = 16
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
}

variable "server_security_group_id" {
  description = "Server security group ID"
}

variable "public_subnets" {
  description = "Public subnets"
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
