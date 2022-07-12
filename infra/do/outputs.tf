output "servers" {
  value = module.do_instance.ips
}

output "lb_address" {
  value = "http://${module.do_instance.lb_address}"
}


