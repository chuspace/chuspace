module "eu_west_shared_resources" {
  source = "../shared/vpc"

  region             = "eu-west-1"
  vpc_azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_cidr           = "10.0.0.0/16"
  vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  name               = "chuspace-app"
  whitelist_ip       = "0.0.0.0/0"
}

module "eu_north_shared_resources" {
  source = "../shared/vpc"

  region              = "eu-north-1"
  vpc_azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  vpc_cidr            = "10.1.0.0/16"
  vpc_public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  name                = "chuspace-app"
  whitelist_ip        = "0.0.0.0/0"
}

module "eu_west_servers" {
  source = "../shared/server"

  region = "eu-west-1"
  name   = "chuspace-app"

  server_security_group_id  = module.eu_west_shared_resources.app_sg_id
  public_subnets            = module.eu_west_shared_resources.public_subnets
  iam_instance_profile_name = module.eu_west_shared_resources.iam_instance_profile_name
  vpc_id                    =  module.eu_west_shared_resources.vpc_id

  instance_type        = "t3.small"
  server_count         = 2
}

module "eu_north_servers" {
  source = "../shared/server"

  region = "eu-north-1"
  name   = "chuspace-app"

  server_security_group_id  = module.eu_north_shared_resources.app_sg_id
  public_subnets            = module.eu_north_shared_resources.public_subnets
  iam_instance_profile_name = module.eu_north_shared_resources.iam_instance_profile_name
  vpc_id                    =  module.eu_north_shared_resources.vpc_id

  instance_type             = "t3.small"
  server_count              = 2
}
