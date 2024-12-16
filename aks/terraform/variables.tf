variable "subscription" {
  type        = string
  description = "The Azure subscription that the cluster will reside in."
}

variable "region" {
  type        = string
  description = "The Azure region where this cluster will reside."
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to all resources created by this module."
}

################################################################################
# Network
################################################################################

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (VNET, Subnets, etc) must be created externally."
}

variable "vnet_cidr" {
  type        = string
  default     = ""
  description = "The CIDR of the cluster's VNET and subnet."
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the subnet ID must be provided."
}

variable "route_table_id" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the route table ID must be provided."
}

################################################################################
# Bastion
################################################################################

variable "create_bastion" {
  type        = bool
  default     = true
  description = "Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately."
}

variable "bastion_ssh_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the SSH port (22) on the bastion host."
}

variable "bastion_ssh_public_key" {
  type        = string
  default     = ""
  description = "The public key that will be added to the authorized keys file on the bastion host for SSH access."
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "kubernetes_service_cidr" {
  type        = string
  default     = "10.100.0.0/16"
  description = "The CIDR used to assign IPs to kubernetes services, internal to the cluster."
}

variable "kubernetes_dns_service_ip" {
  type        = string
  default     = "10.100.0.10"
  description = "The IP address within the service CIDR that will be used for kube-dns."
}

variable "kubernetes_pod_cidr" {
  type        = string
  default     = "10.101.0.0/16"
  description = "The CIDR used to assign IPs to kubernetes services, internal to the cluster."
}

variable "node_pool_max_size" {
  type        = number
  default     = 10
  description = "The maximum size for the broker node pools in the cluster."
}

variable "outbound_ip_count" {
  type        = number
  default     = 2
  description = "The number of public IPs assigned to the load balancer that performs NAT for the VNET."
}

variable "outbound_ports_allocated" {
  type        = number
  default     = 896
  description = "The number of outbound ports allocated for NAT for each VM within the VNET."
}

variable "worker_node_ssh_public_key" {
  type        = string
  description = "The public key that will be added to the authorized keys file on the worker nodes for SSH access."
}

variable "kubernetes_api_public_access" {
  type        = bool
  default     = false
  description = "When set to true, the Kubernetes API is accessible publically from the provided authorized networks."
}

variable "kubernetes_api_authorized_networks" {
  type        = list(string)
  default     = []
  description = "A list of CIDRs that can access the Kubernetes API, in addition to the VPC's CIDR (which is added by default)."
}

variable "local_account_disabled" {
  type        = bool
  default     = true
  description = "By default, AKS has an admin account that can be used to access the cluster with static credentials. It's better to leave this disabled and use Azure RBAC, but it can be enabled if required."
}

variable "kubernetes_cluster_admin_groups" {
  type        = list(string)
  default     = []
  description = "A list of Azure AD group object IDs that will have the Admin Role for the cluster."
}

variable "kubernetes_cluster_admin_users" {
  type        = list(string)
  default     = []
  description = "A list of Azure AD users that will be assigned the 'Azure Kubernetes Service Cluster User Role' role for this cluster."
}

variable "messaging_node_pools" {
  type = map(object({
    vm_size = string
  }))

  default = {
    "prod1k" = {
      vm_size = "Standard_E2ds_v5"
    },
    "prod5k" = {
      vm_size = "Standard_E4ds_v5"
    }
    "prod10k" = {
      vm_size = "Standard_E4bds_v5"
    },
    "prod50k" = {
      vm_size = "Standard_E8bds_v5"
    },
    "prod100k" = {
      vm_size = "Standard_E8bds_v5"
    },
  }

  description = "The configuration for the messaging node pools."
}

variable "system_vm_size" {
  type        = string
  default     = "Standard_D2s_v5"
  description = "The default VM size for the worker nodes in the default (system) node pool."
}

variable "monitoring_vm_size" {
  type        = string
  default     = "Standard_D2s_v5"
  description = "The default VM size for the worker nodes in the monitoring node pool."
}