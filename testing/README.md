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

By default the test cleans up the cluster automatically after the test is run. If you want to keep the cluster around for testing after, set the `KEEP_CLUSTER` environment variable before running the tests:

```bash
export KEEP_CLUSTER=true
go test -v -timeout 60m
```

To clean up, unset KEEP_CLUSTER and run the tests:

```bash
unset KEEP_CLUSTER
go test -v -timeout 60m
```
