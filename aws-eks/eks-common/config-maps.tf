data "aws_iam_role" "node" {
  name = "${local.cluster_name}-node-role"
}

locals {
  users = [
    {
      name = "david.chou"
      arn  = "arn:aws:iam::553321195691:user/david74"
    },
  ]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- rolearn: ${data.aws_iam_role.node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${local.users[0].arn}
  username: ${local.users[0].name}
  groups:
    - ${local.eks_console_access_group}
YAML
  }
}