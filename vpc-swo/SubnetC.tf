resource "aws_subnet" "public_subnet_c" {
  vpc_id                                      = aws_vpc.vpc_swo.id
  enable_resource_name_dns_a_record_on_launch = true
  cidr_block                                  = var.public_subnets.c
  availability_zone                           = "us-east-1c"

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "public_subnet_c"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.vpc_swo.id
  cidr_block        = var.private_subnets.c
  availability_zone = "us-east-1c"

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "private_subnet_c"
  }
}

resource "aws_route_table_association" "rt_association_5" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "route_table_association_28" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.rt_private.id
}

