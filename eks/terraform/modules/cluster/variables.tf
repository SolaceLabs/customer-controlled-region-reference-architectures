variable "region" {
  type        = string
  description = "The AWS region where this cluster will reside."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to all resources created by this module, in the cases where this cannot be accomplished with 'default_tags' on the AWS provider."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the cluster will reside."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The IDs of the private subnets where the worker nodes will reside."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "kubernetes_service_cidr" {
  type        = string
  default     = null
  description = "The CIDR used to assign IPs to kubernetes services, internal to the cluster."
}

variable "node_group_max_size" {
  type        = number
  default     = 10
  description = "The maximum size for the broker node groups in the cluster."
}

variable "kubernetes_api_public_access" {
  type        = bool
  default     = false
  description = "When set to true, the Kubernetes API is accessible publically from the provided authorized networks."
}

variable "kubernetes_api_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default)."
}

variable "kubernetes_cluster_auth_mode" {
  type        = string
  default     = null
  description = "This controls which authentication method to use for the cluster. See the readme for more details."
}

variable "kubernetes_cluster_admin_arns" {
  type        = list(string)
  default     = []
  description = "When kubernetes_cluster_auth_mode is set to 'API', user or role ARNs can be provided that will be given assigned AmazonEKSClusterAdminPolicy for this cluster."
}

variable "use_random_suffix_in_node_group_name" {
  description = "Whether to use auto generated random suffix in node group name"
  type        = bool
  default     = true
}

variable "use_irsa_v1" {
  type        = bool
  default     = true
  description = "When set to true, the module will use IRSA v1 for attaching IAM roles to service accounts."
}

variable "use_irsa_v2" {
  type        = bool
  default     = false
  description = "When set to true, the module will use IRSA v2 for attaching IAM roles to service accounts."
}
