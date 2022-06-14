output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_azs" {
  value = module.vpc.azs
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.instance_profile.name
}
