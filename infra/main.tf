terraform {
  backend "s3" {
    bucket         = "chuspace-infra-bucket"
    key            = "state/docker/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

##############################################
# Provider: AWS
# Region: EU
##############################################

module "aws_eu_west" {
  source = "./aws"
  region = "eu-west-1"

  server_count              = 2
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "eu-west-1"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}

module "aws_eu_central" {
  source = "./aws"
  region = "eu-central-1"

  server_count              = 2
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "eu-central-1"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}

##############################################
# Provider: AWS
# Region: APAC
##############################################

module "aws_apac_south" {
  source = "./aws"
  region = "ap-south-1"

  server_count              = 2
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "ap-south-1"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}

module "aws_apac_southeast" {
  source = "./aws"
  region = "ap-southeast-2"

  server_count              = 2
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "ap-southeast-2"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}

##############################################
# Provider: DO
# Region: US
##############################################

module "do_us_west" {
  source = "./do"
  region = "sfo3"

  server_count              = 2
  do_token                  = var.do_token
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "us-west-1"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}

module "do_us_east" {
  source = "./do"
  region = "nyc1"

  server_count              = 2
  do_token                  = var.do_token
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "us-east-1"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}

##############################################
# Provider: DO
# Region: APAC
##############################################

module "do_apac_sgp" {
  source = "./do"
  region = "sgp1"

  server_count              = 2
  do_token                  = var.do_token
  weave_cloud_token         = var.weave_cloud_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = "eu-west-1"
  aws_ssm_secret_key_name   = "ap-southeast-sgp"
  docker_swarm_token        = var.docker_swarm_token
  docker_swarm_address      = var.docker_swarm_address
}



