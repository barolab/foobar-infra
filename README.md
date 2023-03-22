# Foobar Infrastructure

A set of Google Cloud Project and Kubernetes to deploy the [foobar-api](https://github.com/containous/foobar-api).

## Getting Started

This project uses multiple tools to provision and maintain all the infrastructure resources.
To manage each CLI tool, we suggest to use [asdf](https://asdf-vm.com/).

For this project, you'll need the following plugins:

```sh
# Install the plugins
asdf plugin add terraform kubectl gcloud
# Then install the tools at the proper version
asdf install
```

Some extra steps are required for the `gcloud` CLI to work properly with GKE:

```sh
# First step is to install the components used to get GKE credentials:
$ gcloud components install gke-gcloud-auth-plugin

# With ASDF this add an extra binary inside the gcloud install directory
# You'll have to add the path above in your $PATH
export PATH="$HOME/.asdf/installs/gcloud/423.0.0/bin/:$PATH"
```

A `Makefile` is at your disposal to interact with the repository:

```sh
make fmt          # Format all the source code
make tf-init      # Initialize all the Terraform modules
make tf-apply     # Apply the Terraform modules
make tf-destroy   # Destroy the Terraform modules
make tf-teardown  # Destroy only the GKE clusters (€€€)
```

## Read More

- [Setup](./docs/setup.md)
- [GCP](./docs/gcp.md)
- [Terraform](./docs/terraform.md)

## Todo List

Because there's always room for improvements !

[ ] Linter & Formatter automation
[ ] Check some [GCP Best Practices](https://www.whizlabs.com/blog/gcp-best-practices/)
[ ] Use a [GCP Service Account](https://developer.hashicorp.com/terraform/language/settings/backends/gcs#running-terraform-on-google-cloud)
[ ] GitOps for Terraform with Flux [terraform-controller](https://github.com/weaveworks/tf-controller)
[ ] Find an alternative to change `$PATH` for the [gke-gcloud-auth-plugin](./docs/setud.md#environments-variables) binary
[ ] Use `gcloud config configurations` to set the project ID and pass it down to `terraform` (see the [CLI documentation](https://cloud.google.com/sdk/gcloud/reference/config/configurations))
