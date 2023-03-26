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
    geo {
      location = "europe-west9"
      rrdatas  = [local.proxy_eu_ip]
    }
    geo {
      location = "us-east1"
      rrdatas  = [local.proxy_us_ip]
    }
  }
}
