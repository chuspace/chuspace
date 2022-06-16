# AWS servers

# APAC
output "aws_apac_south_servers" {
  value = module.aws_apac.ap_south_servers
}

output "aws_apac_south_lb" {
  value = module.aws_apac.ap_south_servers_lb_address
}

output "aws_apac_southeast_servers" {
  value = module.aws_apac.ap_southeast_servers
}

output "aws_apac_southeast_lb" {
  value = module.aws_apac.ap_southeast_servers_lb_address
}

# EU

output "aws_eu_west_servers" {
  value = module.aws_eu.eu_west_servers
}

output "aws_eu_west_lb" {
  value = module.aws_eu.eu_west_server_lb_address
}

output "aws_eu_central_servers" {
  value = module.aws_eu.eu_central_servers
}

output "aws_eu_central_lb" {
  value = module.aws_eu.eu_central_server_lb_address
}

# Digital ocean servers

# US

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




