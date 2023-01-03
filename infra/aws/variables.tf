variable "region" {
  description = "Region to deploy to"
  default     = "eu-west-1"
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
}

variable "docker_access_token" {
  description = "Docker access token"
}

