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

# Don't forget to set the GCP project ID (or use a new configuration)
$ gcloud project --set project foobar-XXXXXXXXXX
```

## Environments Variables

Some environment variables are mandatory to work with this repository.
Here's a quick overview as a code snippet:

```sh
# First thing is to add the gcloud component above in your $PATH
# With ASDF the component binary os inside the gcloud install directory
export PATH="$HOME/.asdf/installs/gcloud/423.0.0/bin/:$PATH"

# The GCP project in which you're working, as a Terraform input variable
export TF_VAR_project="foobar-XXXXXXX"
# A Github PAT with Read/Write permissions on the settings of the repositories you want to reconcile with Flux
export GITHUB_TOKEN="XXXXXXX"
```

## Todo List

Because there's always room for improvements !

[ ] Linter & Formatter automation
[ ] Find an alternative to change `$PATH` for the [gke-gcloud-auth-plugin](./docs/setud.md#environments-variables) binary
[ ] Use `gcloud config configurations` to set the project ID and pass it down to `terraform` (see the [CLI documentation](https://cloud.google.com/sdk/gcloud/reference/config/configurations))
