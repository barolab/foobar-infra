# Setup

This documentation will help you get started with all the tooling & stuff required to interact with this repository.
I tried to make it as simple as it can be, but still, there's still a couple of manual things.

## CLI tools

This repository uses multiple tools to provision and maintain all the infrastructure resources.
To manage all of them, I suggest to use [asdf](https://asdf-vm.com/).

You'll need the following plugins:

```sh
# Install the plugins
asdf plugin add terraform kubectl gcloud
# Then install the tools at the proper version
asdf install
```

You can check the tools are properly installed and at the correct version:

```sh
$ terraform version
Terraform v1.4.2
on linux_amd64

$ kubectl version --client --short
Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.24.12

$gcloud version
Google Cloud SDK 423.0.0
...
```

Some extra steps are required for the `gcloud` CLI to work properly with GKE (see the [official GCP documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)).

```sh
# Make sure you're logged in
$ gcloud auth application-default login

# First step is to install the components used to get GKE credentials:
$ gcloud components install gke-gcloud-auth-plugin

# Then enable the mandatory services
$ gcloud services enable "dns.googleapis.com"
$ gcloud services enable "container.googleapis.com"

# In order for the above to work, you'll need to update your PATH
# to make sure the gka auth plugin is available
export PATH="$HOME/.asdf/installs/gcloud/423.0.0/bin/:$PATH"

# Don't forget to set the GCP project ID (or use a new configuration)
$ gcloud config set project foobar-XXXXXXXXXX
```

## Environments Variables

In order to work with Terraform, you'll need to pass a bunch of variables.
They're common to all Terraform modules, so my suggestion is to use a `.env`
file at the root of this repository (with the ZSH `dotenv` plugin to source it automatically).

Here's what it looks like:

```sh
# The GCP Project ID, used in the Makefile to get the GKE KUBECONFIG files
GCP_PROJECT="foobar-XXXXXXX"

# The Github PAT with admin setting on the repository
# It will be used by Terraform to create the Deployment Keys used by Flux to access the private repo over SSH
GITHUB_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXX"

# The GCP Project where the GKE clusters will be created
TF_VAR_project="foobar-XXXXXXX"
# The DNS to host our Foobar API
TF_VAR_domain="raimon.dev"

# The Github account (PAT) with read access to packages, it will be used by GKE to pull artifacts from GHCR
TF_VAR_ghcr_user="XXXXXXX"
TF_VAR_ghcr_email="XXXXXXX"
TF_VAR_ghcr_password="XXXXXXXXXXXXXXXXXXXXXXXX"
```

## Todo List

Because there's always room for improvements !

[ ] Linter & Formatter automation
[ ] Find an alternative to change `$PATH` for the [gke-gcloud-auth-plugin](./docs/setud.md#environments-variables) binary
[ ] Use `gcloud config configurations` to set the project ID and pass it down to `terraform` (see the [CLI documentation](https://cloud.google.com/sdk/gcloud/reference/config/configurations))
