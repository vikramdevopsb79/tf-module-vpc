output "lb_subnet" {
  value = aws_subnet.lb.cidr_block
}