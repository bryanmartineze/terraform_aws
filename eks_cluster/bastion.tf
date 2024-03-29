#Create Keypar

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#Fetching latest amazon linux 2023
data "aws_ami" "latest_amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

#Creation of Bastion Instance
resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.latest_amazon_linux_2023.id  # Replace with the AMI ID of your desired Linux distribution
  instance_type = "t2.micro"  # Adjust as needed

  key_name      = aws_key_pair.bastion_key.key_name
  security_groups = [aws_security_group.bastion.id]

  subnet_id = aws_subnet.public_subnet_a.id  # Replace with the subnet ID in the same VPC as the EKS cluster

  tags = {
    Name = "Bastion-EKS"
  }
}


# Output the private key content
output "bastion_key" {
  sensitive = true
  value = tls_private_key.rsa.private_key_pem
}