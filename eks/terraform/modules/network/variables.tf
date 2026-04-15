variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (VPC, Subnets, etc) must be created externally."
}

variable "vpc_cidr" {
  type        = string
  default     = null
  description = "The CIDR of the cluster's VPC."
}

variable "secondary_vpc_cidr" {
  type        = string
  default     = null
  description = "An optional secondary CIDR block to associate with the cluster's VPC. This can be used to expand the cluster's available IP address space without needing to create a new VPC and migrate resources."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three public subnets. These will contain the bastion host, NAT gateways, and internet-facing load balancer ENIs (if desired)."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three private subnets. These will contain the EKS cluster's master ENIs, worker nodes, and internal load-balancer ENIs (if desired)."
}

variable "preferred_availability_zone_ids" {
  type        = list(string)
  default     = []
  description = "The preferred availability zones to use for the created subnets, specified by ZoneId (eg. 'use1-az1') -- not ZoneName (eg. 'us-east-1a'). If no specific zones are required, leave empty."
}

variable "secondary_private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three private subnets from the secondary CIDR block. These will contain worker nodes and internal load-balancer ENIs (if desired). These subnets will use the same NAT gateways as the primary private subnets."
}
