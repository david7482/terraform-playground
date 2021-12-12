locals {
  terraform_role_arn = "arn:aws:iam::553321195691:role/david74-terraform"
  cluster_name       = "${var.cluster_name}-${var.env}"
}

################################
# AWS
################################
provider "aws" {
  profile = "david74"
  region  = var.region

  assume_role {
    role_arn     = local.terraform_role_arn
    session_name = "david74-eks-cluster-prerequisites"
  }
}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

// because our aws provide has already assumed role properly, this cluster auth would also
// get token via the assumed role.
data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

################################
# Kubernetes
################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

################################
# Helm
################################
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}