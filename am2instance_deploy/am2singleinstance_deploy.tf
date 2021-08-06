
#Create security group with firewall rules
resource "aws_security_group" "enable_ssh" {

  name        = "enable_ssh"
  description = "security group for am2"

# inbound from am2 instances
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound from am2 instances
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "enable_ssh"
  }
}

#Select the most recent instance
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

#Create the instance
resource "aws_instance" "amlinux2" {
  count = 2
  ami           = data.aws_ami.amazon_linux_2.id
  key_name = var.key_name
  instance_type = var.instance_type
  security_groups = ["enable_ssh"]
  iam_instance_profile = "SSMRoleEC2"
  


  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = "true"

    tags = {
      Name = "amlinux2-single-ebs"
    }
  }


  tags = {
    Name = "amlinux2-single"
  }

}


