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
