output "servers" {
  value = module.aws_instance.ips
}

output "lb_address" {
  value = "http://${module.aws_instance.lb_address}"
}


