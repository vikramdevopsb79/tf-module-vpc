data "aws_vpc_peering_connection" "pc" {
  vpc_id          = aws_vpc.main.id
  peer_cidr_block = "10.0.1.0/22"
}

