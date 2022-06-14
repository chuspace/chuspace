output "us_nyc_servers" {
  value = module.us_nyc_servers.server_ips
}

output "us_nyc_servers_lb_address" {
  value = module.us_nyc_servers.app_lb_address
}

output "us_sfo_servers" {
  value = module.us_sfo_servers.server_ips
}

output "us_sfo_servers_lb_address" {
  value = module.us_sfo_servers.app_lb_address
}

output "us_tor_servers" {
  value = module.us_tor_servers.server_ips
}

output "us_tor_servers_lb_address" {
  value = module.us_tor_servers.app_lb_address
}


