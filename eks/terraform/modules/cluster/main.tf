locals {
  cluster_autoscaler_service_account      = "cluster-autoscaler"
  loadbalancer_controller_service_account = "aws-load-balancer-controller"

  default_instance_type    = "m5.large"
  prod1k_instance_type     = "r5.large"
  prod10k_instance_type    = "r5.xlarge"
  prod100k_instance_type   = "r5.2xlarge"
  monitoring_instance_type = "t3.medium"

  worker_node_volume_size = 20
  worker_node_volume_type = "gp2"
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
# Cluster IAM
################################################################################

data "tls_certificate" "eks_oidc_issuer" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

module "cluster_autoscaler_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-cluster-autoscaler"
  policy_name_prefix = "${var.cluster_name}-"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [aws_eks_cluster.cluster.id]

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster.arn
      namespace_service_accounts = ["kube-system:${local.cluster_autoscaler_service_account}"]
    }
  }
}

module "loadbalancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-loadbalancer-controller"
  policy_name_prefix = "${var.cluster_name}-"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster.arn
      namespace_service_accounts = ["kube-system:${local.loadbalancer_controller_service_account}"]
    }
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-ebs-csi"
  policy_name_prefix = "${var.cluster_name}-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster.arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-vpc-cni"
  policy_name_prefix = "${var.cluster_name}-"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster.arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

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
    authentication_mode                         = var.kubernetes_cluster_auth_mode
    bootstrap_cluster_creator_admin_permissions = var.kubernetes_cluster_auth_mode == "CONFIG_MAP" ? true : null
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

  lifecycle {
    precondition {
      condition     = var.kubernetes_cluster_auth_mode == "API" || var.kubernetes_cluster_auth_mode == "API_AND_CONFIG_MAP"
      error_message = "The kubernetes_cluster_auth_mode variable must be set to 'API' or 'API_AND_CONFIG_MAP' if kubernetes_cluster_admin_arns is provided."
    }
  }
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
# Add-ons
################################################################################

resource "aws_eks_addon" "csi-driver" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.default
  ]
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "vpc-cni"
  service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
    env = {
      WARM_IP_TARGET  = "1"
      WARM_ENI_TARGET = "0"
    }
  })
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.default
  ]
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.default
  ]
}

################################################################################
# Worker Node IAM
################################################################################

locals {
  resources_tags = [
    {
      key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
      value = "${local.worker_node_volume_size}G"
    }
  ]
}

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

################################################################################
# Node Group - Default
################################################################################

resource "aws_launch_template" "default" {
  name = "${var.cluster_name}-default"

  vpc_security_group_ids = [aws_security_group.worker_node.id]
  instance_type          = local.default_instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = local.worker_node_volume_size
      volume_type           = local.worker_node_volume_type
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    #checkov:skip=CKV_AWS_341:Two hops are required for various build-in services to work properly
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
    http_tokens                 = "required"
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name           = aws_eks_cluster.cluster.name
  node_group_name_prefix = "${var.cluster_name}-default-"
  node_role_arn          = aws_iam_role.worker_node.arn
  subnet_ids             = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  launch_template {
    id      = aws_launch_template.default.id
    version = aws_launch_template.default.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.worker_node_AmazonSSMManagedInstanceCore,
  ]

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}

resource "aws_autoscaling_group_tag" "default_name_tag" {
  autoscaling_group_name = aws_eks_node_group.default.resources[0].autoscaling_groups[0].name

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-default"
    propagate_at_launch = true
  }
}

################################################################################
# Node Groups - Broker
################################################################################

module "node_group_prod1k" {
  source = "../broker-node-group"

  cluster_name           = aws_eks_cluster.cluster.name
  node_group_name_prefix = "${var.cluster_name}-prod1k"
  security_group_ids     = [aws_security_group.worker_node.id]
  subnet_ids             = var.private_subnet_ids

  worker_node_role_arn      = aws_iam_role.worker_node.arn
  worker_node_instance_type = local.prod1k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod1k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod1k"
      effect = "NO_EXECUTE"
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

module "node_group_prod10k" {
  source = "../broker-node-group"

  cluster_name           = aws_eks_cluster.cluster.name
  node_group_name_prefix = "${var.cluster_name}-prod10k"
  security_group_ids     = [aws_security_group.worker_node.id]
  subnet_ids             = var.private_subnet_ids

  worker_node_role_arn      = aws_iam_role.worker_node.arn
  worker_node_instance_type = local.prod10k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod10k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod10k"
      effect = "NO_EXECUTE"
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

module "node_group_prod100k" {
  source = "../broker-node-group"

  cluster_name           = aws_eks_cluster.cluster.name
  node_group_name_prefix = "${var.cluster_name}-prod100k"
  security_group_ids     = [aws_security_group.worker_node.id]
  subnet_ids             = var.private_subnet_ids

  worker_node_role_arn      = aws_iam_role.worker_node.arn
  worker_node_instance_type = local.prod100k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod100k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod100k"
      effect = "NO_EXECUTE"
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

module "node_group_monitoring" {
  source = "../broker-node-group"

  cluster_name           = aws_eks_cluster.cluster.name
  node_group_name_prefix = "${var.cluster_name}-monitoring"
  security_group_ids     = [aws_security_group.worker_node.id]
  subnet_ids             = var.private_subnet_ids

  worker_node_role_arn      = aws_iam_role.worker_node.arn
  worker_node_instance_type = local.monitoring_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  node_group_labels = {
    nodeType = "monitoring"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "monitoring"
      effect = "NO_EXECUTE"
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

################################################################################
# Output Heredocs
################################################################################

locals {
  cluster_autoscaler_helm_values = <<HELMVALUES
awsRegion: ${var.region}
autoDiscovery:
  clusterName: ${var.cluster_name}
extraArgs:
  scale-down-delay-after-add: 5m
  scale-down-unneeded-time: 5m
replicaCount: 2
rbac:
  serviceAccount:
    name: ${local.cluster_autoscaler_service_account}
    annotations:
      eks.amazonaws.com/role-arn: ${try(module.cluster_autoscaler_irsa_role.iam_role_arn, "")}
HELMVALUES

  load_balancer_controller_helm_values = <<HELMVALUES
clusterName: ${var.cluster_name}
serviceAccount:
  name: ${local.loadbalancer_controller_service_account}
  annotations:
    eks.amazonaws.com/role-arn: ${try(module.loadbalancer_controller_irsa_role.iam_role_arn, "")}
HELMVALUES
}