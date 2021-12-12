terraform {
  backend "s3" {
    profile              = "david74"
    region               = "us-west-2"
    bucket               = "david74-terraform-remote-state-storage"
    key                  = "terraform.tfstate"
    encrypt              = true
    workspace_key_prefix = "david74-eks-cluster-prerequisites"
    role_arn             = "arn:aws:iam::553321195691:role/david74-terraform"
  }
}
