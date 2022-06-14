output "app_lb_address" {
  value = aws_lb.app.dns_name
}

output "server_ips" {
  value = aws_instance.server.*.public_ip
}
