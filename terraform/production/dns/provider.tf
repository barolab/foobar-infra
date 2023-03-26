terraform {
  backend "gcs" {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "production/dns"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.51.0, < 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18.0"
    }
  }
}

# Default provider used to create DNS records
provider "google" {
  project = var.project
  region  = "europe-west9"
}

# Current credentials
data "google_client_config" "default" {}

# Provider pointing to EU
provider "google" {
  alias   = "eu"
  region  = "europe-west9"
  project = var.project
}

data "terraform_remote_state" "eu" {
  backend = "gcs"
  config = {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "production/eu-west9"
  }
}

provider "kubernetes" {
  alias                  = "eu"
  host                   = "https://${data.terraform_remote_state.eu.outputs.kubernetes.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eu.outputs.kubernetes.ca_certificate)
}

# Provider pointing to US
provider "google" {
  alias   = "us"
  region  = "us-east1"
  project = var.project
}

data "terraform_remote_state" "us" {
  backend = "gcs"
  config = {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "production/us-east1"
  }
}

provider "kubernetes" {
  alias                  = "us"
  host                   = "https://${data.terraform_remote_state.us.outputs.kubernetes.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.us.outputs.kubernetes.ca_certificate)
}
