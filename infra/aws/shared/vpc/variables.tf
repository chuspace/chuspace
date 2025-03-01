variable "region" {
  description = "The AWS region to deploy to."
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "chuspace-docker-app-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Environment = "production"
    App         = "chuspace-docker-app"
  }
}

variable "whitelist_ip" {
  description = "IP to whitelist for the security groups (set 0.0.0.0/0 for world)"
}
