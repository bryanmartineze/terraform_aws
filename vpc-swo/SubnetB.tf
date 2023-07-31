resource "aws_subnet" "public_subnet_b" {
  vpc_id                                      = aws_vpc.vpc_swo.id
  enable_resource_name_dns_a_record_on_launch = true
  cidr_block                                  = var.public_subnets.b
  availability_zone                           = "us-east-1b"

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "public_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_swo.id
  cidr_block        = var.private_subnets.b
  availability_zone = "us-east-1b"

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "private_subnet_b"
  }
}

resource "aws_route_table_association" "rt_association_3" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_association_4" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.rt_private.id
}

