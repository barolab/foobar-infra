variable "project" {
  description = "The ID of the GCP project where the resource will be set"
  type        = string
}

variable "ghcr_user" {
  description = "The username of the GHCR user who will pull artefacts"
  type        = string
}

variable "ghcr_email" {
  description = "The email of the GHCR user who will pull artefacts"
  type        = string
}

variable "ghcr_password" {
  description = "The password of the GHCR user who will pull artefacts"
  type        = string
}

variable "grafana_prometheus_url" {
  description = "The Grafana Cloud Prometheus remote write URL"
  type        = string
}

variable "grafana_prometheus_username" {
  description = "The Grafana Cloud Prometheus remote write username"
  type        = string
}

variable "grafana_prometheus_password" {
  description = "The Grafana Cloud Prometheus remote write password"
  type        = string
}

variable "grafana_loki_url" {
  description = "The Grafana Cloud Loki URL"
  type        = string
}

variable "grafana_loki_username" {
  description = "The Grafana Cloud Loki username"
  type        = string
}

variable "grafana_loki_password" {
  description = "The Grafana Cloud Loki password"
  type        = string
}

locals {
  region = "europe-west9"
  zones  = ["europe-west9-a", "europe-west9-b", "europe-west9-c"]

  cluster = {
    name = "foobar-${local.region}"
  }

  namespaces = {
    foobar             = {}
    kube-network       = {}
    kube-security      = {}
    kube-observability = {}
  }
}
