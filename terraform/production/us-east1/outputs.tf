output "network" {
  description = "ID & Name of the network in this region"
  value = {
    id   = module.network.network_id
    name = module.network.network_name
  }
}
