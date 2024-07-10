resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr_block
  tags = local.vpc_tags
}

# resource "aws_subnet" "main" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet_cidr_block
#
#   tags = {
#     Name = "${env-vpc}"
#   }
# }
#
# # Create a route table
# resource "aws_route_table" "rt" {
#   vpc_id = aws_vpc.main.id
# }
#
# # Create a route
# resource "aws_route" "r" {
#   route_table_id            = aws_route_table.rt.id
#   destination_cidr_block    = data.aws_vpc_peering_connection.pc.peer_cidr_block
#   vpc_peering_connection_id = data.aws_vpc_peering_connection.pc.id
# }
