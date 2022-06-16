output "ap_south_servers" {
  value = module.ap_south_servers.server_ips
}

output "ap_south_servers_lb_address" {
  value = "http://${module.ap_south_servers.app_lb_address}"
}

output "ap_southeast_servers" {
  value = module.ap_southeast_servers.server_ips
}

output "ap_southeast_servers_lb_address" {
  value = "http://${module.ap_southeast_servers.app_lb_address}"
}
