output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_azs" {
  value = module.vpc.azs
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "sg_id" {
  value = aws_security_group.sg.id
}
