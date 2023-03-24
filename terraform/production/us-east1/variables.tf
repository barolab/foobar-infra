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

# It seems there is no zone `-a` in GCP us-east1
# See https://cloud.google.com/compute/docs/regions-zones?hl=fr
locals {
  region = "us-east1"
  zones  = ["us-east1-b", "us-east1-c", "us-east1-d"]

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
