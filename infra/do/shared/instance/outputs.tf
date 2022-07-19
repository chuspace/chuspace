output "lb_address" {
  value = digitalocean_loadbalancer.app.urn
}

output "ips" {
  value = digitalocean_droplet.app.*.ipv4_address
}
