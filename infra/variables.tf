variable "region" {
  description = "Region to deploy to"
  default     = "eu-west-1"
}

# variable "do_token" {
#   description = "DO access token"
# }

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



