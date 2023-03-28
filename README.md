# Foobar Infrastructure

A set of Google Cloud Project and Kubernetes resources to deploy the [foobar-api](https://github.com/containous/foobar-api).

[![GitHub Super-Linter](https://github.com/barolab/foobar-infra/workflows/lint/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Getting Started

A `Makefile` is at your disposal to interact with the repository:

```sh
Usage:
  make <target>

Targets:
  fmt             Format the Terraform code
  lint            Lint all source code
  tf-init         Init the terraform modules
  tf-init-eu      Init the terraform GKE module (EU)
  tf-init-us      Init the terraform GKE module (US)
  tf-init-dns     Init the terraform DNS module
  tf-apply        Apply the terraform modules
  tf-apply-eu     Apply the terraform module (EU)
  tf-apply-us     Apply the terraform module (US)
  tf-destroy      Destroy the terraform modules
  tf-destroy-eu   Destroy the terraform module (EU)
  tf-destroy-us   Destroy the terraform module (US)
  tf-teardown     Destroy the GKE clusters
  tf-teardown-eu  Destroy the GKE cluster (EU)
  tf-teardown-us  Destroy the GKE cluster (US)
  kube-init-eu    Get the Kubernetes contexts and put them in ~/.kube/foobar-eu  (EU)
  kube-init-us    Get the Kubernetes contexts and put them in ~/.kube/foobar-us (US)
  help            Print this help message
```

## Read More

If you want to dive into the code and start playing with the repository, check the [setup documentation](./docs/setup.md) and start playing around!

If you're interested about the architecture, the reasoning and the choices made here, check the [challenge documentation](./docs/challenge.md)
