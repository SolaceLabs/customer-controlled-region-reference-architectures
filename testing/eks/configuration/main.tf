resource "kubernetes_manifest" "storageclass_gp3" {
  manifest = yamldecode(file(var.storage_class_path_gp3))
}

resource "kubernetes_manifest" "storageclass_gp2" {
  manifest = merge(yamldecode(file(var.storage_class_path_gp2)), { metadata = { name = "gp2-test" } })
}

resource "helm_release" "cluster_autoscaler" {
  name      = "cluster-autoscaler"
  namespace = "kube-system"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.43.2"

  set {
    name  = "image.tag"
    value = var.cluster_autoscaler_version
  }

  values = [
    var.cluster_autoscaler_helm_values
  ]
}

resource "helm_release" "load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.10.1"

  values = [
    var.load_balancer_controller_helm_values
  ]
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.main.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.main.certificate_authority[0].data}
  name: ${data.aws_eks_cluster.main.arn}
contexts:
- context:
    cluster: ${data.aws_eks_cluster.main.arn}
    user: user
  name: ${data.aws_eks_cluster.main.arn}
current-context: ${data.aws_eks_cluster.main.arn}
kind: Config
preferences: {}
users:
- name: user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
      - --region
      - ${var.region}
      - eks
      - get-token
      - --cluster-name
      - ${var.cluster_name}
KUBECONFIG
}