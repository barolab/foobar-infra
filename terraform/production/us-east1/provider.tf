terraform {
  backend "gcs" {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "production/us-east1"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.51.0, < 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
  }
}

provider "google" {
  region = local.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

