# Foobar Infrastructure

A set of Google Cloud Project and Kubernetes resources to deploy the [foobar-api](https://github.com/containous/foobar-api).

## Getting Started

A `Makefile` is at your disposal to interact with the repository:

```sh
Usage:
  make <target>

Targets:
  fmt             Format the Terraform code
  tf-init         Initialize the terraform modules
  tf-apply        Apply the terraform modules
  tf-destroy      Destroy the terraform modules
  tf-teardown     Destroy only the terraform resources that costs $$$
  kube-init       Get the Kubernetes contexts and put them in ~/.kube/foobar
  help            Print this help message
```

## Read More

If you want to dive into the code and start playing with the repository, check the [setup documentation](./docs/setup.md) and start playing around!

If you're interested about the architecture, the reasoning and the choices made here, check the [challenge documentation](./docs/challenge.md)
