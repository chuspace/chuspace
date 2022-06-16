output "eu_west_servers" {
  value = module.eu_west_servers.server_ips
}

output "eu_west_server_lb_address" {
  value = "http://${module.eu_west_servers.app_lb_address}"
}

output "eu_central_servers" {
  value = module.eu_central_servers.server_ips
}

output "eu_central_server_lb_address" {
  value = "http://${module.eu_central_servers.app_lb_address}"
}
