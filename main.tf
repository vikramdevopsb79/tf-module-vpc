resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr_block
  tags = local.vpc_tags
}

resource "aws_subnet" "lb" {
  count = length(var.lb_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.lb_subnet_cidr[count.index]
 availability_zone = var.azs[count.index]
  tags = {
    Name = local.lb_subnet_tags
  }
}
resource "aws_subnet" "eks" {
  count = length(var.eks_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.eks_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = local.eks_subnet_tags
  }
}
resource "aws_subnet" "db" {
count = length(var.db_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = local.db_subnet_tags
  }
}
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
