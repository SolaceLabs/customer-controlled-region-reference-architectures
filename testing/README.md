# Testing

This folder contains [Terratest](https://terratest.gruntwork.io/) tests for each Terraform project. The intent of the tests is to validate that workloads can be created that simulate real Solace Cloud workloads.

Each cloud test is run independently and each perform the following:

1) Cluster creation with publicly-accessible Kubernetes API
2) Configuration of any dependencies in the cluster (Storage Class, etc)
3) Creation of and validation of test resources
4) Complete cleanup of all infrastructure

## Running

To run the tests, first install `Go >=1.18` then go to the desired directory and run:

```bash
go mod download
go test -v -timeout 60m
```

Note, for GKE the Google Cloud project must set before running any tests:

```bash
export TF_VAR_project=<project-name>
```

By default the test cleans up the cluster automatically after the test is run. If you want to keep the cluster around for testing after, set the `KEEP_CLUSTER` environment variable to `yes` before running the tests (any other value, or unset, destroys the cluster):

```bash
export KEEP_CLUSTER=yes
go test -v -timeout 60m
```

To iterate against the same cluster across runs, also pin `CLUSTER_SUFFIX` to a
stable value so the cluster name and local Terraform state are reused:

```bash
export KEEP_CLUSTER=yes
export CLUSTER_SUFFIX=myrun   # keep within the per-test name-length limit
go test -v -timeout 60m -run TestTerraformGkeClusterComplete
```

To clean up, unset KEEP_CLUSTER (with the same CLUSTER_SUFFIX) and run the tests:

```bash
unset KEEP_CLUSTER
go test -v -timeout 60m
```

### GKE: access to a private API endpoint via the bastion

`TestTerraformGkeClusterComplete` creates the cluster with a **private**
Kubernetes API endpoint and reaches it through the bastion host over an SSH
SOCKS5 proxy, rather than allow-listing the test runner's public IP on the API.
This makes the test independent of the runner's egress IP (useful when an office
has multiple possible egress IPs). Requirements:

* the `ssh` client must be on `PATH`
* the bastion SSH firewall is opened to `0.0.0.0/0` (key-based auth only)

The other GKE tests (`...MessagingCidr`, `...ExternalNetwork`) run without a
bastion and still use the public endpoint with an authorized-network allow-list.
