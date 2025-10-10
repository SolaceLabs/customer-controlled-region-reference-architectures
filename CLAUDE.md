# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains Terraform reference architectures for deploying Kubernetes clusters for Solace Cloud on three major cloud providers: AWS EKS, Azure AKS, and Google Cloud GKE. The clusters are designed to host Solace Cloud event broker services in Customer-Controlled Regions.

## Architecture

Each cloud provider implementation follows a similar modular structure:

- **Network Module**: Creates VPC/VNET with subnets across availability zones (optional, can use existing network)
- **Cluster Module**: Creates the managed Kubernetes cluster with appropriate configuration
- **Bastion Module**: Optional jump host for cluster access when API is private
- **Node Pool/Group Modules**: Creates separate node pools/groups for different broker service scaling tiers

### Key Design Patterns

1. **1:1 Pod-to-Node Ratio**: Each event broker service pod runs on its own dedicated worker node
2. **Node Pool Segregation**: Uses labels and taints to ensure broker pods only schedule on appropriate nodes:
   - `nodeType:messaging` + `serviceClass:{prod1k,prod5k,prod10k,prod50k,prod100k}`
   - `nodeType:monitoring` for monitoring workloads
3. **Availability Zone Distribution**: Node pools are designed to support pod anti-affinity to distribute HA broker services across zones
4. **Modular Network**: All implementations support BYO (bring your own) network configuration

### Scaling Tiers

Each implementation supports these broker service classes:
- **prod1k**: Smallest production tier
- **prod5k**: Medium tier (EKS only)
- **prod10k**: Large tier
- **prod50k**: X-Large tier (EKS only)
- **prod100k**: Largest tier
- **monitoring**: For monitoring/sidecar workloads

## Directory Structure

```
.
├── eks/          # AWS EKS implementation
├── aks/          # Azure AKS implementation
├── gke/          # Google Cloud GKE implementation
└── testing/      # Terratest integration tests
```

Each cloud directory contains:
- `terraform/`: Main Terraform code with modules
- `kubernetes/`: Kubernetes manifests (storage classes, etc.)
- `connect.sh`: Helper script to configure kubectl access via bastion
- `docs/`: Architecture diagrams

## Common Development Commands

### Terraform Operations

Navigate to the appropriate cloud provider directory (e.g., `eks/terraform/`, `aks/terraform/`, `gke/terraform/`) first:

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate
```

### Testing

Tests use Terratest (Go-based testing framework). Navigate to the test directory (e.g., `testing/eks/`, `testing/aks/`, `testing/gke/`):

```bash
# Download Go dependencies
go mod download

# Run tests (creates real infrastructure, then validates and destroys)
go test -v -timeout 60m

# Keep infrastructure after testing (for debugging)
export KEEP_CLUSTER=true
go test -v -timeout 60m

# Clean up test infrastructure
unset KEEP_CLUSTER
go test -v -timeout 60m
```

**Note**: For GKE tests, set the project first: `export TF_VAR_project=<project-name>`

### Cluster Access

After creating a cluster, use the provider-specific method:

**EKS with bastion:**
```bash
source ./connect.sh --private-key <path-to-ssh-key>
```

**EKS with public API:**
```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

**AKS with bastion:**
```bash
source ./connect.sh --private-key <path-to-ssh-key>
```

**AKS with public API:**
```bash
az aks get-credentials --resource-group <rg-name> --name <cluster-name>
```

**GKE with bastion:**
```bash
source ./connect.sh --private-key <path-to-ssh-key>
```

**GKE with public API:**
```bash
gcloud container clusters get-credentials <cluster-name> --region <region>
```

## Important Configuration Notes

### EKS-Specific

- Uses EKS Pod Identities for workload IAM permissions (not IRSA)
- Cluster authentication mode is API-based (not ConfigMap)
- VPC CNI configured with `WARM_IP_TARGET=1` and `WARM_ENI_TARGET=0` for efficient IP usage
- Requires deployment of cluster-autoscaler and aws-load-balancer-controller via Helm (see `eks/README.md`)
- Worker nodes use Amazon Linux 2023
- Instance type `r6in` family may not be available in all regions

### AKS-Specific

- Uses Kubenet networking (not Azure CNI) for efficient IP usage
- Cluster autoscaler is built-in, no separate deployment needed
- Default node pool cannot be moved out of cluster module (Azure limitation)
- Azure RBAC enabled by default
- Uses managed instance groups per AZ

### GKE-Specific

- Uses VPC-native networking with separate secondary CIDR ranges for:
  - Services (non-routable)
  - Pods (routable if messaging pods CIDR not defined)
  - Messaging pods (optional, routable)
- Default max_pods_per_node: 16 for system nodes, 8 for messaging nodes
- Cluster autoscaler is built-in, no separate deployment needed
- Node pools automatically span AZs via managed instance groups

## Terraform Variables

Each implementation requires a `terraform.tfvars` file. Key required variables:

**All providers:**
- `cluster_name`: Unique cluster name
- `kubernetes_version`: Must match Solace Cloud supported versions (check documentation)
- `bastion_ssh_authorized_networks`: CIDRs allowed to SSH to bastion
- `bastion_ssh_public_key`: SSH public key for bastion access

**EKS:**
- `region`: AWS region
- `vpc_cidr`: VPC CIDR (size appropriately using Solace CIDR Calculator)
- `public_subnet_cidrs`: 3 public subnet CIDRs
- `private_subnet_cidrs`: 3 private subnet CIDRs
- `kubernetes_cluster_admin_arns`: IAM user/role ARNs for cluster admin access

**AKS:**
- `region`: Azure region
- `vnet_cidr`: VNET CIDR (use Solace CIDR Calculator with 'AKS Kubenet' sheet)
- `worker_node_ssh_public_key`: SSH key for worker nodes
- `kubernetes_cluster_admin_users` or `kubernetes_cluster_admin_groups`: Azure AD principals for cluster access

**GKE:**
- `project`: GCP project ID
- `region`: GCP region
- `network_cidr_range`: Primary network CIDR
- `secondary_cidr_range_services`: Services CIDR (non-routable)
- `secondary_cidr_range_pods`: Pods CIDR (routable)
- `secondary_cidr_range_messaging_pods`: Optional messaging pods CIDR (routable)

## Version Information

- Terraform: ~> 1.3
- AWS Provider: ~> 5.0
- Azure Provider: Version specified in `aks/terraform/versions.tf`
- Google Provider: Version specified in `gke/terraform/versions.tf`

## Project Versioning

This repository is on v2 of the Terraform projects. Key changes from v1:

- **EKS**: Removed IRSA method, moved node groups to main project from cluster module
- **AKS**: Moved messaging node pools to main project (system pool remains in cluster module)
- **GKE**: Breaking changes to secondary CIDR configuration (moved from cluster to subnetwork for smaller cluster support)

## External Dependencies

Required tools:
- Terraform 1.3+ (recommend using tfenv for version management)
- Cloud provider CLI (aws-cli, az-cli, or gcloud)
- kubectl
- helm
- yq
- Go 1.18+ (for running tests)

## Storage Classes

After cluster creation, deploy the appropriate storage class:

**EKS:** `kubectl apply -f kubernetes/storage-class-gp2.yaml` (recommended) or `storage-class-gp3.yaml`

**AKS:** `kubectl apply -f kubernetes/storage-class.yaml`

**GKE:** `kubectl apply -f kubernetes/storage-class.yaml`

## Additional Resources

- Solace Cloud Documentation: https://docs.solace.com/Cloud/
- CIDR Calculator: Check Solace docs for the Excel calculator to size networks appropriately
- Supported Kubernetes Versions: https://docs.solace.com/Cloud/Deployment-Considerations/cloud-broker-k8s-versions-support.htm
