# AWS servers

output "aws_apac_south_servers" {
  value = module.aws_apac.ap_south_servers
}

output "aws_apac_south_lb" {
  value = module.aws_apac.ap_south_servers_lb_address
}

output "aws_apac_east_servers" {
  value = module.aws_apac.ap_east_servers
}

output "aws_apac_east_lb" {
  value = module.aws_apac.ap_east_servers_lb_address
}

output "aws_eu_west_servers" {
  value = module.aws_eu.eu_west_servers
}

output "aws_eu_west_lb" {
  value = module.aws_eu.eu_west_server_lb_address
}

output "aws_eu_north_servers" {
  value = module.aws_eu.eu_north_servers
}

output "aws_eu_north_lb" {
  value = module.aws_eu.eu_north_server_lb_address
}

# Digital ocean servers

output "do_us_nyc_servers" {
  value = module.do_us.us_nyc_servers
}

output "do_us_nyc_servers_lb_address" {
  value = "http://${module.do_us.us_nyc_servers_lb_address}"
}

output "do_us_sfo_servers" {
  value = module.do_us.us_sfo_servers
}

output "do_us_sfo_servers_lb_address" {
  value = "http://${module.do_us.us_sfo_servers_lb_address}"
}

output "do_us_tor_servers" {
  value = module.do_us.us_tor_servers
}

output "do_us_tor_servers_lb_address" {
  value = "http://${module.do_us.us_tor_servers_lb_address}"
}




