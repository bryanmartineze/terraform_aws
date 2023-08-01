terraform {
  cloud {
    organization = "bryanmartineze-devops"

    workspaces {
      name = "cicd-pipeline-example"
    }
  }
  
    required_providers {
    aws = {
      version = ">= 5.6.2"
    }
  }
}

variable "aws_region" {
    
}

provider "aws" {
  region = var.aws_region
}