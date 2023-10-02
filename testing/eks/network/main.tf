locals {
  vpc_cidr = "10.10.0.0/24"

  public_subnet_cidrs = [
    "10.10.0.0/28",
    "10.10.0.16/28",
    "10.10.0.32/28"
  ]

  private_subnet_cidrs = [
    "10.10.0.64/26",
    "10.10.0.128/26",
    "10.10.0.192/26"
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = var.cluster_name
  cidr = local.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  one_nat_gateway_per_az = true

  enable_flow_log = false

  vpc_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}