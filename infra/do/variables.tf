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
variable "docker_access_token" {
  description = "Docker access token"
}


