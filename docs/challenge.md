# Challenge

The purpose of this repository is to answer to a challenge that was given me: Deploy a full Kubernetes platform in two different regions to host the [foobar-api](https://github.com/containous/foobar-api).

## Introduction

The first step is to make some choices regarding the infrastructure. Given the challenge description I see two requirements:

1. The Foobar API must run in Kubernetes
2. It must run in two different regions (with cross-region load balancing in mind)

The first decision made was to go with `GKE`, for a couple of reasons:

1. I don't know anything about `GKE`, but I'm very curious because most comparison I saw put it in first place
2. It seems most of the default addons are builtin, I don't have to bother with `kube-proxy` or the `CNI` for this challenge
3. It's an opportunity to learn more about `GCP`

I didn't want to spend too much time on deploying those resources (`GCP` or `Kubernetes`), so I decided to use tools that I'm familiar with:

1. `terraform` to manage the `GCP` resources
2. `flux` to manage the `Kubernetes` resources

Along the challenge implementation, I will try to note every decision where I believe it could be done better.
Given the time frame, my schedule and my limited bank account, I will probably have to cut corners (especially in terms of security)

## Step 1 - Kubernetes Clusters

The first step is to initialize the Kubernetes clusters with `GCP` and `terraform`.

Let's begin by registering a [GCP account](https://console.cloud.google.com/home/dashboard), and create a project (mine is called `foobar`). Then follow the [setup documentation](./setud.md) to install the and configure the CLI tools.

Before we start creating GKE clusters, we'll first create a GCS bucket to store our Terraform state:

```sh
terraform -chdir=./terraform/root/storage init
terraform -chdir=./terraform/root/storage apply
```

The bucket has versioning enabled in case you want to revert to a previous state.
And the Terraform GCS backend supports locking by default !
That should prevent concurrent execution of Terraform modules

Once this is done we can start the modules in charge of the GKE clusters:

1. [eu-west9](../terraform/production/eu-west9/main.tf)
2. [us-east1](../terraform/production/us-east1/main.tf)

> The code used here is heavily inspired by the example of the [Terraform GKE module](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/examples)

Here's a quick overview of the Terraform code used to spin up the GKE clusters:

```terraform
# Uses the google network module to create a VPC for the GKE cluster
# - It has one primary subnet for the nodes and the control planes (10.0.0.0/16)
# - A secondary subnet for PODs (192.168.0.0/18)
# - A secondary subnet for Services (192.168.64.0/18)

module "network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 4.0.1"

  network_name = "${local.cluster.name}-network"
  subnets = [
    {
      subnet_name   = "${local.cluster.name}-subnet"
      subnet_ip     = "10.0.0.0/20"
      subnet_region = local.region
    },
  ]

  secondary_ranges = {
    "${local.cluster.name}-subnet" = [
      {
        range_name    = "${local.cluster.name}-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "${local.cluster.name}-services"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

# Now we create the GKE cluster, giving it the network subnets created above
# It'll will deploy the latest version (1.24) with e2-small (cheap, general purpose instances) nodes
module "gke" {
  source      = "terraform-google-modules/kubernetes-engine/google"
  name        = local.cluster.name
  zones       = local.zones
  region      = local.region
  regional    = true
  description = "Foobar GKE in ${local.region}"

  # Networking
  network           = module.network.network_name
  subnetwork        = module.network.subnets_names[0]
  ip_range_pods     = module.network.subnets_secondary_ranges[0].*.range_name[0]
  ip_range_services = module.network.subnets_secondary_ranges[0].*.range_name[1]

  # Version
  release_channel    = "STABLE"
  kubernetes_version = "1.24"

  # Security
  remove_default_node_pool = true
  service_account          = "create"

  # Node pools
  node_pools = [
    {
      name         = "default-small"
      machine_type = "e2-small"
      min_count    = 1
      max_count    = 2
      auto_upgrade = true
      auto_repair  = true
      disk_size_gb = 20
      disk_type    = "pd-standard"
    }
  ]
}
```

We can test on Europe with the following commands:

```sh
# Run terraform to create the VPC + GKE cluster (~5-10 minutes)
$ terraform -chdir=terraform/production/eu-west9/ init
$ terraform -chdir=terraform/production/eu-west9/ apply

# Get access to the GKE cluster
$ export KUBECONFIG=~/.kube/foobar
$ gcloud container clusters get-credentials foobar-europe-west9 --region=europe-west9

# Check it's working fine
$ kubectl get nodes
$ kubectl get pods -A

# Once it's validated, you can delete the GKE cluster to avoid being billed too much
$ terraform -chdir=terraform/production/eu-west9/ destroy -target=module.gke
```

Done ! We now have two GKE clusters in two different regions, next step will be to deploy things on those clusters using Flux

**Improvements**

- [ ] Manage the GCP project ID a bit differently (en environment variable on a laptop is error prone)
- [ ] GitOps the Terraform modules, either with TF Cloud or Flux [terraform-controller](https://github.com/weaveworks/tf-controller)
- [ ] Use a [GCP Service Account](https://developer.hashicorp.com/terraform/language/settings/backends/gcs#running-terraform-on-google-cloud) for Terraform
- [ ] Check some [GCP Best Practices](https://www.whizlabs.com/blog/gcp-best-practices/)
