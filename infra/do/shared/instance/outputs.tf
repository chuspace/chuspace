output "lb_address" {
  value = digitalocean_loadbalancer.chuspace_app.urn
}

output "ips" {
  value = digitalocean_droplet.chuspace_app.*.ipv4_address
}
