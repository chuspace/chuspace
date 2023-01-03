terraform {
  backend "s3" {
    bucket  = "chuspace-infra-bucket"
    key     = "state/docker/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

##############################################
# Provider: AWS
# Region: EU West
##############################################

# module "aws_eu_west" {
#   source = "./aws"
#   region = "eu-west-1"

#   server_count              = 3
#   docker_access_token       = var.docker_access_token
# }

# module "aws_eu_central" {
#   source = "./aws"
#   region = "eu-central-1"

#   server_count              = 2
#   docker_access_token       = var.docker_access_token
# }

##############################################
# Provider: AWS
# Region: APAC
##############################################

# module "aws_apac_south" {
#   source = "./aws"
#   region = "ap-south-1"

#   server_count              = 2
#   docker_access_token       = var.docker_access_token
# }

# module "aws_apac_southeast" {
#   source = "./aws"
#   region = "ap-southeast-2"

#   server_count              = 2
#   docker_access_token       = var.docker_access_token
# }

##############################################
# Provider: DO
# Region: US
##############################################

# module "do_us_west" {
#   source = "./do"
#   region = "sfo3"

#   server_count              = 2
#   do_token                  = var.do_token
#   docker_access_token       = var.docker_access_token
# }

# module "do_us_east" {
#   source = "./do"
#   region = "nyc1"

#   server_count              = 2
#   do_token                  = var.do_token
#   docker_access_token       = var.docker_access_token
# }

##############################################
# Provider: DO
# Region: APAC
##############################################

module "do_apac_eu" {
  source = "./do"
  region = "lon1"

  server_count        = 2
  do_token            = var.do_token
  docker_access_token = var.docker_access_token
}



