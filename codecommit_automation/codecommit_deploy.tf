resource "aws_codecommit_repository" "terraform_repo" {
  repository_name = "esxi_terraform_repo"
  description     = "Git repo to store Terraform scripts to automate esxi config"
}