################################
# Security Group
################################
resource "aws_security_group" "node" {
  name        = "${local.cluster_name}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                        = "${local.cluster_name}-node-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "Environment"                                 = var.env
    "Purpose"                                     = "${local.cluster_name}-node-sg"
  }
}

resource "aws_security_group_rule" "nodes_ingress_self" {
  description              = "Allow node to communicate with each other"
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

################################
# IAM
################################
resource "aws_iam_role" "node" {
  name = "${local.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "node_group_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_group_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_group_ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_group_ssm_agent" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node.name
}

################################
# EKS Node Group: spot
################################
data "cloudinit_config" "ssm_agent" {
  gzip          = false
  base64_encode = true
  boundary      = "==BOUNDARY=="

  part {
    content_type = "text/x-shellscript"
    content      = "yum install -y https://s3.us-west-2.amazonaws.com/amazon-ssm-us-west-2/latest/linux_amd64/amazon-ssm-agent.rpm"
  }
}

resource "random_id" "launch_template_spot_random" {
  keepers = {
    version = 1
  }

  byte_length = 2
}

resource "aws_launch_template" "spot" {
  name                   = "${local.cluster_name}-spot-launch-template-${random_id.launch_template_spot_random.hex}"
  update_default_version = true
  ebs_optimized          = true
  vpc_security_group_ids = [aws_security_group.node.id]
  user_data              = data.cloudinit_config.ssm_agent.rendered

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.cluster_name}-spot-node"
      Environment = var.env
      Purpose     = "${local.cluster_name}-spot-node"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${local.cluster_name}-spot-node"
      Environment = var.env
      Purpose     = "${local.cluster_name}-spot-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "node_group_spot_random" {
  keepers = {
    version = 3
  }

  byte_length = 2
}

resource "aws_eks_node_group" "spot" {
  node_group_name = "${local.cluster_name}-spot-ng-${random_id.node_group_spot_random.hex}"

  ami_type       = "AL2_x86_64"
  cluster_name   = local.cluster_name
  node_role_arn  = aws_iam_role.node.arn
  subnet_ids     = data.aws_subnet_ids.private.ids
  instance_types = ["t3.small"]
  capacity_type  = "SPOT"

  launch_template {
    id      = aws_launch_template.spot.id
    version = aws_launch_template.spot.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 1
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  labels = {
    purpose = "spot"
  }

  tags = {
    Name        = "${local.cluster_name}-spot-ng-${random_id.node_group_spot_random.hex}"
    Environment = var.env
    Purpose     = "${local.cluster_name}-spot-ng-${random_id.node_group_spot_random.hex}"
  }
}