[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

# Kubernetes Terraform Reference Architectures for Solace Cloud

## Overview

[Solace Cloud](https://solace.com/products/event-broker/cloud/) provides multiple [deployment options](https://solace.com/resources/datasheets/deployment-options-for-pubsub-event-broker-cloud-datasheet) designed to meet various customer requirements. These Terraform projects provide a reference architecture for a Kubernetes cluster running in a [Customer-Controlled Region](https://docs.solace.com/Cloud/Deployment-Considerations/deployment-options.htm). The reference architectures include recommendations for:

 * Node groups/pools with labels and taints for simple scheduling
 * VM sizes for each scaling tier that meet our [resource requirements](https://docs.solace.com/Cloud/Deployment-Considerations/resource-requirements-k8s.htm)
 * Network configuration (including use of [availability zones](https://docs.solace.com/Cloud/Deployment-Considerations/deployment-architecture-k8s.htm)
 * Recommended settings for storage classes
 * Configuration of required components (CSI, Austoscaler, Load Balancer Controller, etc)

The reference architectures *do not* provide best practices for running Kubernetes. They are intended to provide an example that will provide easy integration with Solace Cloud.

Reference architectures are available for:

 * [Amazon Elastic Kubernetes Service (EKS)](eks/README.md)
 * [Azure Kubernetes Service (AKS)](aks/README.md)
 * [Google Kubernetes Engine (GKE)](gke/README.md)

The Kubernetes versions supported in Solace Cloud for EKS, AKS, and GKE are found in [Supported Kubernetes Versions](https://docs.solace.com/Cloud/Deployment-Considerations/cloud-broker-k8s-versions-support.htm) on the Solace documentation website.

## Resources

This is not an officially supported Solace product.

For more information try these resources:
- Ask the [Solace Community](https://solace.community)
- The Solace Developer Portal website at: https://solace.dev

If you have issues with your Solace Cloud deployment, please contact [Support](https://solace.com/support/).

## Contributing

Contributions are encouraged! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

See the list of [contributors](https://github.com/solacelabs/customer-controlled-region-reference-architectures/graphs/contributors) who participated in this project.
## License

See the [LICENSE](LICENSE) file for details.