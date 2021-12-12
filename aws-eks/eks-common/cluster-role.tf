locals {
  eks_console_access_group = "eks-console-dashboard-full-access-group"
}

// Create a ClusterRole with necessary permission for EKS console dashboard, and
// role-binding it with the group. Then, we will map the IAM role with the group in aws-auth config-maps.
// https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting_iam.html#security-iam-troubleshoot-ConfigMap
resource "kubernetes_cluster_role" "eks_console_full_access_cluster_role" {
  metadata {
    name = "eks-console-dashboard-full-access-clusterrole"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "namespaces", "pods", "events"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "eks_console_full_access_role_binding" {
  metadata {
    name = "eks-console-dashboard-full-access-binding"
  }
  subject {
    kind      = "Group"
    name      = local.eks_console_access_group
    api_group = "rbac.authorization.k8s.io"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.eks_console_full_access_cluster_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}