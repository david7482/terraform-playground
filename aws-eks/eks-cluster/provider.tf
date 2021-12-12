terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "david74"
  region  = var.region

  assume_role {
    role_arn     = "arn:aws:iam::553321195691:role/david74-terraform"
    session_name = "david74-eks-cluster"
  }
}
