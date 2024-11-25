locals {
  cluster_autoscaler_service_account      = "cluster-autoscaler"
  loadbalancer_controller_service_account = "aws-load-balancer-controller"
  ebs_csi_controller_service_account      = "ebs-csi-controller-sa"
  vpc_cni_service_account                 = "aws-node"
  controllers_namespace                   = "kube-system"
}

################################################################################
# Pod Identity
################################################################################

module "cluster_autoscaler_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.7.0"

  name               = "${var.cluster_name}-ca"
  policy_name_prefix = "${var.cluster_name}-"

  attach_cluster_autoscaler_policy = true
  use_name_prefix                  = false
  cluster_autoscaler_cluster_names = [var.cluster_id]

  association_defaults = {
    namespace       = local.controllers_namespace
    service_account = local.cluster_autoscaler_service_account
  }

  associations = {
    cluster-autoscaler = {
      cluster_name = var.cluster_id
    }
  }
}

module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.7.0"

  name               = "${var.cluster_name}-lbc"
  policy_name_prefix = "${var.cluster_name}-"

  attach_aws_lb_controller_policy = true
  use_name_prefix                 = false

  association_defaults = {
    namespace       = local.controllers_namespace
    service_account = local.loadbalancer_controller_service_account
  }

  associations = {
    aws-lbc = {
      cluster_name = var.cluster_id
    }
  }

}

module "aws_ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.7.0"

  name               = "${var.cluster_name}-ebs-csi"
  policy_name_prefix = "${var.cluster_name}-"

  attach_aws_ebs_csi_policy = true
  use_name_prefix           = false

  association_defaults = {
    namespace       = local.controllers_namespace
    service_account = local.ebs_csi_controller_service_account
  }

  associations = {
    ebs-csi = {
      cluster_name = var.cluster_id
    }
  }
}

module "aws_vpc_cni_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.7.0"

  name               = "${var.cluster_name}-vpc-cni"
  policy_name_prefix = "${var.cluster_name}-"

  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true
  use_name_prefix           = false

  association_defaults = {
    namespace       = local.controllers_namespace
    service_account = local.vpc_cni_service_account
  }

  associations = {
    vpc-cni = {
      cluster_name = var.cluster_id
    }
  }
}

################################################################################
# Add-ons
################################################################################

resource "aws_eks_addon" "csi-driver" {
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
    controller = {
      extraVolumeTags = var.common_tags
    }
  })

  depends_on = [
    var.default_node_group_arn
  ]
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"

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
  cluster_name = var.cluster_name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    var.default_node_group_arn
  ]
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    var.default_node_group_arn
  ]
}

resource "aws_eks_addon" "pod-identity" {
  cluster_name = var.cluster_name
  addon_name   = "eks-pod-identity-agent"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
}

################################################################################
# Output Heredocs
################################################################################

locals {
  cluster_autoscaler_helm_values = yamlencode({
    awsRegion : var.region,
    autoDiscovery : {
      clusterName : var.cluster_name
    },
    extraArgs : {
      "scale-down-delay-after-add" : "5m",
      "scale-down-unneeded-time" : "5m"
    },
    replicaCount : 2,
    rbac : {
      serviceAccount : {
        name : local.cluster_autoscaler_service_account,
      }
    }
  })

  load_balancer_controller_helm_values = yamlencode({
    clusterName : var.cluster_name,
    serviceAccount : {
      name : local.loadbalancer_controller_service_account,
    }
    defaultTags : var.common_tags
  })
}