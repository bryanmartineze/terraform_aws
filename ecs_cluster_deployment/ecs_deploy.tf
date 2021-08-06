#create VPC "Terraform VPC"
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/20"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "Terraform VPC"
    }
}

#Create internet gateway
resource "aws_internet_gateway" "terraform_internet_gateway" {
    vpc_id = aws_vpc.vpc.id
}

#Create public subnet
resource "aws_subnet" "pub_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.0.0/24"
    map_public_ip_on_launch = true
    
    tags       = {
        Name = "Public_Subnet"
    }
}

#Create Private subnet 1
resource "aws_subnet" "priv_subnet1" {
    availability_zone       = "us-east-2a" 
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = false
    tags       = {
        Name = "Private_Subnet_1"
    }
}

#Create Private subnet 2
resource "aws_subnet" "priv_subnet2" {
    availability_zone       = "us-east-2b" 
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = false
    tags       = {
        Name = "Private_Subnet_2"
    }
}

#Create Private subnet 3
resource "aws_subnet" "priv_subnet3" {
    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = "us-east-2c" 
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = false
    tags       = {
        Name = "Private_Subnet_3"
    }
}

#Create route table for public subnet and attach internet gateway
resource "aws_route_table" "route_table_public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.terraform_internet_gateway.id
    }

    tags       = {
        Name = "Public Subnet Route Table"
    }
}

#Create route table for public subnet 1 (no internet gateway)
resource "aws_route_table" "route_table_private1" {
    vpc_id = aws_vpc.vpc.id

       tags       = {
        Name = "Private_Subnet_1 Route Table"
    }
}

#Create route table for public subnet 1 (no internet gateway)
resource "aws_route_table" "route_table_private2" {
    vpc_id = aws_vpc.vpc.id

       tags       = {
        Name = "Private_Subnet_2 Route Table"
    }
}

#Create route table for public subnet 1 (no internet gateway)
resource "aws_route_table" "route_table_private3" {
    vpc_id = aws_vpc.vpc.id

       tags       = {
        Name = "Private_Subnet_3 Route Table"
    }
}

#Associate public route table with public subnet
resource "aws_route_table_association" "public_route_table_association" {
    subnet_id      = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.route_table_public.id
}

#Associate private route table with private subnet 1
resource "aws_route_table_association" "private_route_table_association1" {
    subnet_id      = aws_subnet.priv_subnet1.id
    route_table_id = aws_route_table.route_table_private1.id
}

#Associate private route table with private subnet 1
resource "aws_route_table_association" "private_route_table_association2" {
    subnet_id      = aws_subnet.priv_subnet2.id
    route_table_id = aws_route_table.route_table_private2.id
}

#Associate private route table with private subnet 1
resource "aws_route_table_association" "private_route_table_association3" {
    subnet_id      = aws_subnet.priv_subnet3.id
    route_table_id = aws_route_table.route_table_private3.id
}

#Create security group with firewall rules for ECS Cluster
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.vpc.id
  name        = "ecs_sg"
  description = "security group for ecs"

# inbound from ecs instances
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound from ecs instances
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_sg"
  }
}

#Create security group with firewall rules for RDS DB
resource "aws_security_group" "rdsDB_sg" {
  vpc_id = aws_vpc.vpc.id
  name        = "ecs_sgrdsDB_sg"
  description = "security group for RDS DB"

# inbound from RDS instance
    ingress {
        protocol        = "tcp"
        from_port       = 3306
        to_port         = 3306
        cidr_blocks     = ["0.0.0.0/0"]
    }

     ingress {
        protocol        = "icmp"
        from_port       = -1
        to_port         = -1
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

  tags = {
    Name = "rdsDB_sg"
  }
}

# Select the most recent instance over AMI Library
    data "aws_ami" "amazon_linux_2" {
        most_recent = true
        owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# Create 3 instances
resource "aws_instance" "ecs-amlinux2" {
  count = 3
  ami           = data.aws_ami.amazon_linux_2.id
  key_name = var.key_name
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  iam_instance_profile = "SSMRoleEC2"
  
  #install docker and docker compose script to be deployed
  user_data = <<-EOF

    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo systemctl enable --now docker
    sudo yum install -y git
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo docker-compose version

     EOF

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = "true"

    tags = {
      Name = "ecs-amlinux2_ebs-${count.index}"
    }
  }


  tags = {
    Name = "ecs-amlinux2-${count.index}"
  }

}

#Create Elastic IP address
resource "aws_eip" "eip_manager" {
 count = 3
 vpc = true
  instance = aws_instance.amlinux2-ecs[count.index].id

tags= {
   Name = "amlinux2_elastic_ip-${count.index}"
  }
}

#Create DB Subnet
resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [aws_subnet.priv_subnet1.id, aws_subnet.priv_subnet2.id, aws_subnet.priv_subnet3.id]
}

resource "aws_db_instance" "ecs-database" {
    identifier                = "mysql"
    allocated_storage         = 5
    backup_retention_period   = 2
    backup_window             = "01:00-01:30"
    maintenance_window        = "sun:03:00-sun:03:30"
    multi_az                  = true
    engine                    = "mysql"
    engine_version            = "8.0"
    instance_class            = "db.t2.micro"
    name                      = "worker_db"
    username                  = "worker"
    password                  = "casiopeaNor030"
    port                      = "3306"
    db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids    = [aws_security_group.rdsDB_sg.id]
    skip_final_snapshot       = true
    final_snapshot_identifier = "worker-final"
    publicly_accessible       = true
}

#Create ecr repository
resource "aws_ecr_repository" "ecs-cluster-registry" {
  name                 = "ecs-cluster-registry"
  image_tag_mutability = "MUTABLE"

  tags = {
    project = "ecs-cluster-registry"
  }
}

#Create the ECS service to manage the docker nodes
resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "ecs-cluster"
}