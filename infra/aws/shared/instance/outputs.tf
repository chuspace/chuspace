output "lb_address" {
  value = aws_lb.app.dns_name
}

output "ips" {
  value = aws_instance.app.*.public_ip
}
