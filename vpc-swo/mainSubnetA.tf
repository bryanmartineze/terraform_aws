resource "aws_subnet" "public_subnet_a" {
  vpc_id                                      = aws_vpc.vpc_swo.id
  enable_resource_name_dns_a_record_on_launch = true
  cidr_block                                  = var.public_subnets.a
  availability_zone                           = "us-east-1a"

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "public_subnet_a"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.public_subnet_a.id
  allocation_id = aws_eip.nat_gateway_eip.id

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "nat_gateway_swo"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.vpc_swo.id
  cidr_block        = var.private_subnets.a
  availability_zone = "us-east-1a"

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "private_subnet_a"
  }
}

resource "aws_route_table_association" "rt_association_1" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_association_2" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.rt_private.id
}

