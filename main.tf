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
resource "aws_vpc_peering_connection" "main" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true
}

#  Create a route for main dev vpc
resource "aws_route" "main-vpc" {
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = var.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
#  Create a route for default  vpc
resource "aws_route" "default-vpc" {
  route_table_id            = var.default_vpc_rt
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
# internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags          = local.igw_tags
}
resource "aws_eip" "main" {
  domain = "vpc"
}
# nat gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.lb.*.id[0]
  tags          = local.ngw_tags
}

# Created route table to share traffic between them
resource "aws_route_table" "lb" {
  vpc_id = aws_vpc.main.id
  tags   = local.lb_rt_tags

  route {
    cidr_block                = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

}
# to attach route tables to subnets
resource "aws_route_table_association" "lb" {
  count          = length(aws_subnet.lb.*.id)
  subnet_id      = aws_route_table.lb.id
  route_table_id = aws_subnet.lb.*.id[count.index]
}
resource "aws_route_table" "eks" {
  vpc_id = aws_vpc.main.id
  tags   = local.eks_rt_tags

  route {
    cidr_block                = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

}
resource "aws_route_table_association" "eks" {
  count          = length(aws_subnet.eks.*.id)
  subnet_id      = aws_route_table.eks.id
  route_table_id = aws_subnet.eks.*.id[count.index]
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags   = local.db_rt_tags

  route {
    cidr_block                = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

}
resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db.*.id)
  subnet_id      = aws_route_table.db.id
  route_table_id = aws_subnet.db.*.id[count.index]
}
output "tag_module" {
  value = local.vpc_tags
}

# For testing instance logging with private ip
# resource "aws_security_group" "main" {
#   name        = "test-${var.env}"
#   description = "test-${var.env}"
#   vpc_id      = aws_vpc.main.id
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "SSH Port"
#   }
#
#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }
#
# resource "aws_instance" "web" {
#   ami                    = ""
#   instance_type          = "t3.micro"
#   vpc_security_group_ids = [aws_security_group.main.id]
#   subnet_id              = aws_subnet.eks.*.id[0]
#
#   tags = {
#     Name = "test"
#   }
# }