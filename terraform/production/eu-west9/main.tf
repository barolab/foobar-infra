data "google_client_config" "default" {}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "6.0.1"

  project_id   = var.project
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

module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google"
  version    = "25.0.0"
  project_id = var.project

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
  node_metadata            = "GKE_METADATA"

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

module "flux" {
  source = "../../modules/flux"
  name   = "flux-foobar-eu-west9"

  chart = {
    version = "2.7.0"
  }

  controllers = {
    helm      = { create = true }
    source    = { create = true }
    kustomize = { create = true }
  }

  repositories = {
    foobar-infra = {
      git = {
        url = "ssh://git@github.com/barolab/foobar-infra"
      }

      kustomizations = {
        flux-system = { path = "./kubernetes/production/eu-west9/flux-system" }
      }
    }
  }
}

resource "kubernetes_namespace" "namespace" {
  for_each = local.namespaces

  metadata {
    name = each.key
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "kubernetes_secret" "ghcr" {
  for_each   = local.namespaces
  depends_on = [kubernetes_namespace.namespace]

  metadata {
    name      = "ghcr"
    namespace = each.key
  }

  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          "username" = var.ghcr_user
          "password" = var.ghcr_password
          "email"    = var.ghcr_email
          "auth"     = base64encode("${var.ghcr_user}:${var.ghcr_password}")
        }
      }
    })
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations
    ]
  }
}

module "cert_manager" {
  depends_on = [kubernetes_namespace.namespace]

  source    = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name      = "cert-manager"
  namespace = "kube-security"
  roles     = ["roles/dns.admin"]

  gcp_sa_name = "${local.region}-cert-manager"
  project_id  = var.project
}

# Secret variables pushed to GKE to allow Kustomize to do some substition
resource "kubernetes_config_map" "variables" {
  depends_on = [kubernetes_namespace.namespace]

  metadata {
    name      = "cluster-variables"
    namespace = "flux-system"
  }

  data = {
    gcp_cluster = module.gke.cluster_id
    gcp_project = var.project
    gcp_region  = local.region

    cert_manager_fqdn  = module.cert_manager.gcp_service_account_fqn
    cert_manager_email = module.cert_manager.gcp_service_account_email

    grafana_prometheus_url      = var.grafana_prometheus_url
    grafana_prometheus_username = base64encode(var.grafana_prometheus_username)
    grafana_prometheus_password = base64encode(var.grafana_prometheus_password)
    grafana_loki_url            = var.grafana_loki_url
    grafana_loki_username       = base64encode(var.grafana_loki_username)
    grafana_loki_password       = base64encode(var.grafana_loki_password)
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations
    ]
  }
}
