################################
# Locals
################################
locals {
  cluster_name = "${var.cluster_name}-${var.env}"
}

################################
# Subnets
################################
data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    Purpose = "public-subnet"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    Purpose = "private-subnet"
  }
}

resource "aws_ec2_tag" "subnet_cluster_tag" {
  for_each    = setunion(data.aws_subnet_ids.public.ids, data.aws_subnet_ids.private.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_subnet_elb_tag" {
  for_each    = toset(data.aws_subnet_ids.public.ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnet_elb_tag" {
  for_each    = toset(data.aws_subnet_ids.private.ids)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

################################
# Security Group
################################
resource "aws_security_group" "cluster" {
  name        = "${local.cluster_name}-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.cluster_name}-cluster-sg"
    Environment = var.env
    Purpose     = "${local.cluster_name}-cluster-sg"
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}

################################
# IAM
################################
resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

################################
# EKS cluster
################################
resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = setunion(data.aws_subnet_ids.public.ids, data.aws_subnet_ids.private.ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = local.cluster_name
    Environment = var.env
    Purpose     = local.cluster_name
  }
}