terraform {
  backend "gcs" {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "production/us-east1"
  }

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = " >= 4.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 4.51.0, < 5.0"
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

provider "github" {
  owner = "barolab"
}

provider "google" {
  project = var.project
  region  = local.region
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
