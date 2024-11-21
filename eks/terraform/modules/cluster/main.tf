data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "IAM role for the EKS cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

################################################################################
# Cluster Security Group
################################################################################

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "Security group for the EKS cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-cluster"
  }
}

resource "aws_security_group_rule" "cluster_from_worker_node" {
  description              = "Allow all traffic to cluster from worker nodes"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.worker_node.id
}

################################################################################
# Cluster
################################################################################

resource "aws_kms_key" "secrets" {
  description             = "Secrets encryption in etcd for ${var.cluster_name} EKS cluster"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "secrets" {
  name_prefix   = "alias/${var.cluster_name}-etcd-"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = "true"
    endpoint_public_access  = var.kubernetes_api_public_access
    public_access_cidrs     = var.kubernetes_api_authorized_networks
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.kubernetes_service_cidr
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    provider {
      key_arn = aws_kms_key.secrets.arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  tags = {
    Name = var.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.cluster_logs,
  ]

  lifecycle {
    precondition {
      condition     = !var.kubernetes_api_public_access || length(var.kubernetes_api_authorized_networks) > 0
      error_message = "At least one authorized network must be provided if public Kubernetes API is being created."
    }
  }
}

resource "aws_eks_access_entry" "admin" {
  count = length(var.kubernetes_cluster_admin_arns)

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = var.kubernetes_cluster_admin_arns[count.index]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  count = length(var.kubernetes_cluster_admin_arns)

  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.kubernetes_cluster_admin_arns[count.index]

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin
  ]
}

resource "aws_kms_key" "logs" {
  description             = "Secrets encryption for cloudwatch cluster logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_key_policy" "logs" {
  key_id = aws_kms_key.logs.id
  policy = jsonencode({
    Id = "Key Policy"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Resource = "*"
      },
      {
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Effect = "Allow"
        Principal = {
          "Service" : "logs.${var.region}.amazonaws.com"
        }
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:${data.aws_partition.current.partition}:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.cluster_name}/cluster"
          }
        }
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_kms_alias" "logs" {
  name_prefix   = "alias/${var.cluster_name}-logs-"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_cloudwatch_log_group" "cluster_logs" {
  #checkov:skip=CKV_AWS_338:Solace is not opinionated on how long logs are retained

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.logs.arn

  depends_on = [
    aws_kms_key_policy.logs
  ]
}

################################################################################
# Worker Node IAM
################################################################################

resource "aws_iam_role" "worker_node" {
  name        = "${var.cluster_name}-worker-node"
  description = "IAM role for the worker nodes in the EKS cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.${data.aws_partition.current.dns_suffix}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_node.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_node.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker_node.name
}

################################################################################
# Worker Node Security Group
################################################################################

resource "aws_security_group" "worker_node" {
  #checkov:skip=CKV2_AWS_5:Security group is used in another module

  name        = "${var.cluster_name}-worker-node"
  description = "Security group for all worker nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress"
  }

  tags = {
    "Name"                                      = "${var.cluster_name}-worker-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "worker_node_from_cluster" {
  description              = "Allow all traffic to worker nodes from cluster"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker_node.id
  source_security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "worker_node_to_worker_node" {
  description              = "Allow all traffic to worker nodes from worker nodes"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker_node.id
  source_security_group_id = aws_security_group.worker_node.id
}