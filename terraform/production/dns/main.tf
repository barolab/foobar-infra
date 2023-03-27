data "terraform_remote_state" "dns" {
  backend = "gcs"
  config = {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "root/dns"
  }
}

data "kubernetes_service" "traefik_proxy_eu" {
  provider = kubernetes.eu
  metadata {
    name      = "traefik-proxy-lb"
    namespace = "kube-network"
  }
}

data "kubernetes_service" "traefik_proxy_us" {
  provider = kubernetes.us
  metadata {
    name      = "traefik-proxy-lb"
    namespace = "kube-network"
  }
}

locals {
  proxy_eu_ip = data.kubernetes_service.traefik_proxy_eu.status.0.load_balancer.0.ingress.0.ip
  proxy_us_ip = data.kubernetes_service.traefik_proxy_us.status.0.load_balancer.0.ingress.0.ip
}

resource "google_dns_record_set" "api" {
  name = "api.${var.domain}."
  type = "A"
  ttl  = 30

  managed_zone = data.terraform_remote_state.dns.outputs.public_zone.name

  routing_policy {
    wrr {
      weight   = 0.5
      rrdatas  = [local.proxy_eu_ip]
    }
    wrr {
      weight   = 0.5
      rrdatas  = [local.proxy_us_ip]
    }
  }
}
