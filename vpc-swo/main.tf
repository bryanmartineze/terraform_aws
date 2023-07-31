resource "aws_vpc" "vpc_swo" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "vpc_swo"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_swo.id

  route {
    gateway_id = aws_internet_gateway.internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "rt_public"
  }
}

resource "aws_eip" "nat_gateway_eip" {

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "nat_gateway_eip"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_swo.id

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "igw-swo"
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc_swo.id

  route {
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    env      = "Production"
    archUUID = "31f2ffc5-3feb-40b3-bdeb-4e6f8197f34a"
    Name     = "rt_private"
  }
}

resource "aws_security_group" "security_group_ssh" {
  vpc_id      = aws_vpc.vpc_swo.id
  name        = "ssh-sg"
  description = "allow ssh from anywhere"

  egress {
    to_port   = 0
    protocol  = "-1"
    from_port = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    to_port     = 22
    protocol    = "tcp"
    from_port   = 22
    description = "ssh"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "ssh-sg"
  }
}

