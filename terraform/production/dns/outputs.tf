output "eu_lb" {
  description = "Details about the EU Load Balancer"
  value = data.kubernetes_service.traefik_proxy_eu
}

output "us_lb" {
  description = "Details about the US Load Balancer"
  value = data.kubernetes_service.traefik_proxy_us
}
