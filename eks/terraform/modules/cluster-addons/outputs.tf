output "cluster_autoscaler_helm_values" {
  value = local.cluster_autoscaler_helm_values
}

output "load_balancer_controller_helm_values" {
  value = local.load_balancer_controller_helm_values
}

output "addon_versions" {
  value = {
    ebs_csi      = aws_eks_addon.csi-driver.addon_version
    vpc_cni      = aws_eks_addon.vpc-cni.addon_version
    core_dns     = aws_eks_addon.coredns.addon_version
    kube_proxy   = aws_eks_addon.kube-proxy.addon_version
    pod_identity = aws_eks_addon.pod-identity.addon_version
  }
}