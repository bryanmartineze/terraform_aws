terraform {
  required_providers {
    aws = {
      version = "= 4.28.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
