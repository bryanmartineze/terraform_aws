
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks_cluster.name]
}

resource "aws_eks_cluster" "cicd-example-pipeline" {
  name     = "cicd-example-pipeline"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.25"  # Change this to your desired EKS version
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]
}


resource "aws_eks_node_group" "cicd-example-pipeline_node_group" {
  cluster_name    = aws_eks_cluster.cicd-example-pipeline.name
  node_group_name = "cicd-example-pipeline-node-group"
  instance_type   = "t3.small"  # Change this to your desired instance type
  desired_capacity = 3

  subnet_ids = [
    aws_subnet.private_subnet_a.id,  # Replace with the subnet IDs of your desired AZs
    aws_subnet.private_subnet_b.id,
    aws_subnet.private_subnet_c.id,
  ]
  # Add the block_device_mappings configuration for gp3 volumes
  launch_template {
    block_device_mappings {
      device_name = "/dev/xvda"

      ebs {
        volume_size = 20  # Change this to your desired gp3 volume size in GB
        volume_type = "gp3"
        throughput = 125  # Change this to your desired throughput in MB/s
      }
    }
  }

  depends_on = [
    aws_eks_cluster.cicd-example-pipeline,
  ]
  
}

