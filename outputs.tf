output "lb_subnets" {
  value = aws_subnet.lb.*.id
}