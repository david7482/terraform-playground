locals {
  aws_lb_controller_version       = "2.3.0"
  aws_lb_controller_chart_version = "1.3.2"
}

################################
# IAM
################################
resource "aws_iam_role" "controller" {
  name = "${var.cluster_name}-load-balancer-controller-${var.region}-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        "Federated" : aws_iam_openid_connect_provider.cluster.arn
      }
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.cluster.url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name        = var.cluster_name
    Environment = var.env
    Purpose     = var.cluster_name
  }
}

// The necessary IAM policy is from
// https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/
data "http" "controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${local.aws_lb_controller_version}/docs/install/iam_policy.json"
}

resource "aws_iam_role_policy" "inline" {
  name   = "inline"
  role   = aws_iam_role.controller.id
  policy = data.http.controller_iam_policy.body
}

################################
# Service Account
################################
resource "kubernetes_service_account" "controller" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.controller.arn
    }
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
}

################################
# Helm
################################
resource "helm_release" "controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = local.aws_lb_controller_chart_version
  namespace  = "kube-system"

  values = [yamlencode(
    {
      clusterName = data.aws_eks_cluster.cluster.name
      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }
    }
  )]
}