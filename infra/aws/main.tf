module "aws_vpc" {
  source = "./shared/vpc"

  region             = "${var.region}"
  vpc_azs            = ["${var.region}a", "${var.region}b", "${var.region}c"]
  vpc_cidr           = "10.0.0.0/16"
  vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  vpc_name           = "chuspace-docker-app-vpc"
  whitelist_ip       = "0.0.0.0/0"
}

module "aws_instance" {
  source = "./shared/instance"

  region = "${var.region}"
  name   = "chuspace-docker-app"

  server_security_group_id  = module.aws_vpc.sg_id
  public_subnets            = module.aws_vpc.public_subnets
  vpc_id                    =  module.aws_vpc.vpc_id

  instance_type             = "t3.medium"
  server_count              = var.server_count

  logtail_token             = var.logtail_token
  docker_access_token       = var.docker_access_token
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  aws_region                = var.aws_region
  aws_ssm_secret_key_name   = var.aws_ssm_secret_key_name
}
