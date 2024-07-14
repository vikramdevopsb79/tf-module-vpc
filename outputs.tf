variable "lbsubnets" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}
output "olb_subnets" {
  value = var.lbsubnets
}