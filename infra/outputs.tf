##############################################
# Provider: AWS
##############################################


# EU
output "aws_eu_west_servers" {
  value = module.aws_eu_west.servers
}

output "aws_eu_west_lb_address" {
  value = module.aws_eu_west.lb_address
}

output "aws_eu_central_servers" {
  value = module.aws_eu_central.servers
}

output "aws_eu_central_lb_address" {
  value = module.aws_eu_central.lb_address
}

# APAC
output "aws_apac_south_servers" {
  value = module.aws_apac_south.servers
}

output "aws_apac_south_lb_address" {
  value = module.aws_apac_south.lb_address
}

output "aws_apac_southeast_servers" {
  value = module.aws_apac_southeast.servers
}

output "aws_apac_southeast_lb_address" {
  value = module.aws_apac_southeast.lb_address
}


##############################################
# Provider: DO
##############################################


# US
output "do_us_east_servers" {
  value = module.do_us_east.servers
}

output "do_us_east_lb_address" {
  value = module.do_us_east.lb_address
}

output "do_us_west_servers" {
  value = module.do_us_west.servers
}

output "do_us_west_lb_address" {
  value = module.do_us_west.lb_address
}

# APAC

output "do_apac_sgp_servers" {
  value = module.do_apac_sgp.servers
}

output "do_apac_sgp_lb_address" {
  value = module.do_apac_sgp.lb_address
}

