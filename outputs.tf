output "wp_loadbalancer_address" {
  value = aws_lb.wp_lb.dns_name
}