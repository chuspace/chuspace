module "ap_south_shared_resources" {
  source = "../shared/vpc"

  region             = "ap-south-1"
  vpc_azs            = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  vpc_cidr           = "10.10.0.0/16"
  vpc_public_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
  name               = "chuspace-app"
  whitelist_ip       = "0.0.0.0/0"
}

module "ap_south_servers" {
  source = "../shared/server"

  region = "ap-south-1"
  name   = "chuspace-app"

  server_security_group_id  = module.ap_south_shared_resources.app_sg_id
  public_subnets            = module.ap_south_shared_resources.public_subnets
  iam_instance_profile_name = module.ap_south_shared_resources.iam_instance_profile_name
  vpc_id                    =  module.ap_south_shared_resources.vpc_id

  instance_type        = "t3.small"
  server_count         = 2
}


module "ap_east_shared_resources" {
  source = "../shared/vpc"

  region             = "ap-east-1"
  vpc_azs            = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
  vpc_cidr           = "10.10.0.0/16"
  vpc_public_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
  name               = "chuspace-app"
  whitelist_ip       = "0.0.0.0/0"
}

module "ap_east_servers" {
  source = "../shared/server"

  region = "ap-east-1"
  name   = "chuspace-app"

  server_security_group_id  = module.ap_east_shared_resources.app_sg_id
  public_subnets            = module.ap_east_shared_resources.public_subnets
  iam_instance_profile_name = module.ap_east_shared_resources.iam_instance_profile_name
  vpc_id                    =  module.ap_east_shared_resources.vpc_id

  instance_type        = "t3.small"
  server_count         = 2
}
