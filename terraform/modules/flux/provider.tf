terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = " >= 4.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }

    github = {
      source  = "integrations/github"
      version = ">= 4.24"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18.0"
    }
  }
}
