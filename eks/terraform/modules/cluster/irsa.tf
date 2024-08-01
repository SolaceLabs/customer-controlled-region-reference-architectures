################################################################################
# IRSA v1
################################################################################

data "tls_certificate" "eks_oidc_issuer" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count           = var.use_irsa_v1 ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

moved {
  from = aws_iam_openid_connect_provider.cluster
  to   = aws_iam_openid_connect_provider.cluster[0]
}

module "cluster_autoscaler_irsa_role" {
  count = var.use_irsa_v1 ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-cluster-autoscaler"
  policy_name_prefix = "${var.cluster_name}-"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [aws_eks_cluster.cluster.id]

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster[0].arn
      namespace_service_accounts = ["kube-system:${local.cluster_autoscaler_service_account}"]
    }
  }
}

moved {
  from = module.cluster_autoscaler_irsa_role
  to   = module.cluster_autoscaler_irsa_role[0]
}


module "loadbalancer_controller_irsa_role" {
  count = var.use_irsa_v1 ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-loadbalancer-controller"
  policy_name_prefix = "${var.cluster_name}-"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster[0].arn
      namespace_service_accounts = ["kube-system:${local.loadbalancer_controller_service_account}"]
    }
  }
}

moved {
  from = module.loadbalancer_controller_irsa_role
  to   = module.loadbalancer_controller_irsa_role[0]
}

module "ebs_csi_irsa_role" {
  count = var.use_irsa_v1 ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-ebs-csi"
  policy_name_prefix = "${var.cluster_name}-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster[0].arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

moved {
  from = module.ebs_csi_irsa_role
  to   = module.ebs_csi_irsa_role[0]
}

module "vpc_cni_irsa_role" {
  count = var.use_irsa_v1 ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name          = "${var.cluster_name}-vpc-cni"
  policy_name_prefix = "${var.cluster_name}-"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster[0].arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

moved {
  from = module.vpc_cni_irsa_role
  to   = module.vpc_cni_irsa_role[0]
}

################################################################################
# IRSA v2
################################################################################
module "cluster_autoscaler_pod_identity" {
  count = var.use_irsa_v2 ? 1 : 0

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.3.0"

  name               = "${var.cluster_name}-ca"
  policy_name_prefix = "${var.cluster_name}-"

  attach_cluster_autoscaler_policy = true
  use_name_prefix                  = false
  cluster_autoscaler_cluster_names = [aws_eks_cluster.cluster.id]

  # Pod Identity Associations
  association_defaults = {
    namespace       = local.contorllers_namespace
    service_account = local.cluster_autoscaler_service_account
  }

  associations = {
    cluster-autoscaler = {
      cluster_name = aws_eks_cluster.cluster.id
    }
  }
}

module "aws_lb_controller_pod_identity" {
  count = var.use_irsa_v2 ? 1 : 0

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.3.0"

  name               = "${var.cluster_name}-lbc"
  policy_name_prefix = "${var.cluster_name}-"

  attach_aws_lb_controller_policy = true
  use_name_prefix                 = false

  # Pod Identity Associations
  association_defaults = {
    namespace       = local.contorllers_namespace
    service_account = local.loadbalancer_controller_service_account
  }

  associations = {
    aws-lbc = {
      cluster_name = aws_eks_cluster.cluster.id
    }
  }

}

module "aws_ebs_csi_pod_identity" {
  count = var.use_irsa_v2 ? 1 : 0

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.3.0"

  name               = "${var.cluster_name}-ebs-csi"
  policy_name_prefix = "${var.cluster_name}-"

  attach_aws_ebs_csi_policy = true
  use_name_prefix           = false

  # Pod Identity Associations
  association_defaults = {
    namespace       = local.contorllers_namespace
    service_account = local.ebs_csi_controller_service_account
  }

  associations = {
    ebs-csi = {
      cluster_name = aws_eks_cluster.cluster.id
    }
  }
}

module "aws_vpc_cni_pod_identity" {
  count = var.use_irsa_v2 ? 1 : 0

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.3.0"

  name               = "${var.cluster_name}-vpc-cni"
  policy_name_prefix = "${var.cluster_name}-"

  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true
  use_name_prefix           = false

  # Pod Identity Associations
  association_defaults = {
    namespace       = local.contorllers_namespace
    service_account = local.vpc_cni_service_account
  }

  associations = {
    vpc-cni = {
      cluster_name = aws_eks_cluster.cluster.id
    }
  }
}