# Reference Terraform for STACKIT Kubernetes Engine

We provide a sample Terraform that you can use as a reference to set up your Kubernetes cluster using STACKIT Kubernetes Engine (SKE). This Terraform gives you recommended practices for the cluster to help ensure your deployment of Solace Cloud is successful.

You can review the architecture and understand how to deploy using the Terraform. For information about the architecture, see:
* [Architecture of SKE Reference Terraform](#ske-architecture)
* [Usage of Terraform for SKE](#ske-usage)

## Architecture of the Reference Terraform for STACKIT Kubernetes Engine <a name="ske-architecture"></a>

The sections below describe the architecture of the reference Terraform project for deploying a STACKIT Kubernetes Engine (SKE) cluster. It includes Kubernetes components and configuration that:
* are required (or highly recommended) to operate successfully with Solace Cloud
* are recommended but not required to successfully deploy Solace Cloud
* are available to produce a working cluster but we are not opinionated on what to use (an option or configuration had to be selected as part of the Terraform, but does not impact the installation of Solace Cloud)

The areas to review are the [networking](#ske-network), [cluster configuration](#ske-cluster-config), and [access to and from the cluster](#ske-access).

> An architecture diagram for SKE has not yet been produced. See [`docs/`](docs/) in the AKS / EKS / GKE reference architectures for the analogous layout in those providers.

### Network <a name="ske-network"></a>

The Terraform creates the following network resources:

* A **STACKIT Network Area (SNA)** at the organization level, with the cluster's CIDR registered as its primary network range, plus an optional secondary range for a VPN gateway.
* A **network area region binding** that associates the SNA with the chosen STACKIT region (e.g. `eu01`) and configures the transfer network CIDR.
* A **project-scoped network** that the SKE cluster's worker nodes attach to.

The network area can be reused across multiple projects in the same organization. Cluster networks (one per cluster) live inside a project and consume CIDR space from the SNA.

### Cluster Configuration <a name="ske-cluster-config"></a>

#### Project

Each SKE cluster lives in its own STACKIT project. The Terraform creates the project under the configured organization and tags it with the SNA's network area ID via a label.

#### Availability Zones

STACKIT's `eu01` region has three discrete availability zones (`eu01-1`, `eu01-2`, `eu01-3`) plus a **metro** zone (`eu01-m`) that spans multiple physical zones. The reference architecture uses:
* the metro zone for the system / default pool (STACKIT-managed system components benefit from cross-zone failover)
* discrete zones for messaging pools (one pool per zone, enabling pod anti-affinity across zones for HA brokers)
* one discrete zone (`eu01-3`) for the monitoring pool

#### Node Pools

The cluster has the following node pools. Note: STACKIT does not expose a standalone node-pool resource — pools are defined inline on `stackit_ske_cluster.node_pools`. The reference architecture's `broker-node-pool` module is a config-factory: it produces node-pool config objects, which the top-level Terraform concatenates into the cluster's `node_pools` argument.

##### Default (System)

The default node pool runs on the metro availability zone (`eu01-m`) so STACKIT can automatically migrate system workloads across physical zones on failure. It uses the `c2i.2` flavor, scales from 1 to 3 nodes, and is the only pool with `allow_system_components = true` (which lets cluster-system workloads such as CoreDNS schedule onto it).

##### Event Broker Services

The cluster has 6 node pools for event broker services — two per tier, one in each of `eu01-1` and `eu01-2`. Locking each pool to a single AZ allows the cluster autoscaler to operate predictably and enables pod anti-affinity across zones for HA broker services.

These node pools are engineered to support a 1:1 ratio of event broker service pod to worker node. We use labels and taints on each of these node pools to ensure that only event broker service pods are scheduled on the worker nodes for each scaling tier.

The VM sizes, labels, and taints for each event broker service node pool are as follows (sized to meet Solace Cloud broker resource requirements on STACKIT):

| Name                 | VM size | AZ      | Labels                                          | Taints                                                            |
|----------------------|---------|---------|-------------------------------------------------|-------------------------------------------------------------------|
| prod1k1 / prod1k2    | `m2i.2` | -1 / -2 | nodeType:messaging<br>serviceClass:prod1k       | nodeType:messaging:NoExecute<br>serviceClass:prod1k:NoExecute     |
| prod10k1 / prod10k2  | `m2i.4` | -1 / -2 | nodeType:messaging<br>serviceClass:prod10k      | nodeType:messaging:NoExecute<br>serviceClass:prod10k:NoExecute    |
| prod100k1 / prod100k2| `m2i.8` | -1 / -2 | nodeType:messaging<br>serviceClass:prod100k     | nodeType:messaging:NoExecute<br>serviceClass:prod100k:NoExecute   |
| monitoring           | `g3i.2` | -3      | nodeType:monitoring                             | nodeType:monitoring:NoExecute                                     |

Each pool's nodes use a 50 GiB boot volume on the `storage_premium_perf2` performance class.

### Access <a name="ske-access"></a>

There are two options for cluster access:

 * A **bastion host** (opt-in via `create_bastion = true`) with a public IP, accessible via SSH from provided source CIDRs. The bastion image is referenced by UUID — the Terraform doesn't dynamically look it up because the lookup requires a project that hasn't been created yet at plan time. Set `bastion_image_id` to a current Ubuntu image UUID (find one via `stackit image list`).
 * The cluster's Kubernetes API can be set to **PUBLIC** (the default, accessible from the internet) or **PRIVATE** via `kubernetes_api_access_scope`. When PRIVATE, access requires going through the bastion's network.

## Usage of Terraform for STACKIT Kubernetes Engine <a name="ske-usage"></a>

The following section is an overview of the steps to use this Terraform. Before you begin, review the necessary [prerequisites](#ske-prerequisites). Here's an overview of the steps:

1. [Create the Kubernetes cluster](#ske-create-cluster).
2. [Deploy the recommended storage classes](#ske-deploy-storage).

### Prerequisites <a name="ske-prerequisites"></a>

To use this Terraform module, the following is required:

* Terraform 1.3 or above (we recommend [tfenv](https://github.com/tfutils/tfenv) for Terraform version management)
* [STACKIT CLI](https://github.com/stackitcloud/stackit-cli) for discovering image UUIDs and pulling kubeconfigs
* [yq](https://github.com/mikefarah/yq#install)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* [helm](https://helm.sh/docs/intro/install/)
* A STACKIT service-account key with sufficient permissions to create projects, networks, and SKE clusters in the target organization.

### Creating the Kubernetes Cluster <a name="ske-create-cluster"></a>

1. Configure the STACKIT provider with a service-account key:

    ```bash
    export STACKIT_SERVICE_ACCOUNT_KEY_PATH=/path/to/credentials.json
    ```

2. Find a current Ubuntu image UUID for the bastion (only needed if `create_bastion = true`):

    ```bash
    stackit image list --project-id <any-existing-org-project> | grep -i ubuntu
    ```

3. Navigate to the `terraform/` directory and create a `terraform.tfvars` file with the required variables. See the Terraform [README.md](terraform/README.md) for a full list of variables.

    For example:

    ```hcl
    organization_id = "00000000-0000-0000-0000-000000000000"
    cluster_name    = "solace-eu01"
    owner_email     = "you@example.com"

    region                = "eu01"
    cluster_cidr          = "10.0.0.0/24"
    transfer_network_cidr = "10.1.0.0/16"

    create_bastion          = true
    bastion_image_id        = "<uuid from step 2>"
    bastion_ssh_public_key  = "ssh-rsa abc123..."
    bastion_ssh_source_cidr = "192.168.1.1/32"
    ```

4. Apply the Terraform:

    ```bash
    terraform init
    terraform apply
    ```

5. After you create the cluster, set up access:

    * If the bastion host was created, use the `connect.sh` script to open a tunnel and set up your environment to access the cluster:

        ```bash
        source ./connect.sh --private-key <ssh private key path>
        ```

    * If the Kubernetes API was left at the default `PUBLIC` access scope, a kubeconfig is sufficient:

        ```bash
        stackit ske kubeconfig create <cluster-name> --project-id <project-id>
        kubectl config use-context <cluster-name>
        ```

### Deploying Storage Classes <a name="ske-deploy-storage"></a>

For Solace Cloud broker workloads, two STACKIT block-storage performance classes are recommended: `perf2` for the broker `data` volume and `perf6` for the broker `spool` volume.

> StorageClass manifests for SKE are not yet included in [`kubernetes/`](kubernetes/). The exact provisioner + parameter shape needs validation against a live SKE cluster before publishing. Tracked as a follow-up.
