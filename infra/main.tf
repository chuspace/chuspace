terraform {
  backend "s3" {
    bucket         = "chuspace-infra-bucket"
    key            = "state/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

module "aws_apac" {
  source = "./aws/apac"
}

module "aws_eu" {
  source = "./aws/eu"
}

module "do_us" {
  source = "./do/us"
  do_token = var.do_token
}
