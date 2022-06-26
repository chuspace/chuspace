output "apac_sgp_servers" {
  value = module.apac_sgp_servers.server_ips
}

output "apac_sgp_servers_lb_address" {
  value = module.apac_sgp_servers.app_lb_address
}


