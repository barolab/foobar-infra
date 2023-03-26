output "network" {
  description = "ID & Name of the network in this region"
  value = {
    id   = module.network.network_id
    name = module.network.network_name
  }
}

output "kubernetes" {
  sensitive   = true
  description = "ID & details about our GKE clusters"
  value = {
    id                 = module.gke.cluster_id
    type               = module.gke.type
    location           = module.gke.location
    region             = module.gke.region
    zones              = module.gke.zones
    endpoint           = module.gke.endpoint
    ca_certificate     = module.gke.ca_certificate
    service_account    = module.gke.service_account
    identity_namespace = module.gke.identity_namespace
  }
}

output "cert_manager" {
  sensitive = true
  description = "Destails about the Cert Manager service account"
  value = module.cert_manager
}
