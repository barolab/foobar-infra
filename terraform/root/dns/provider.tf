terraform {
  backend "gcs" {
    bucket = "foobar-raimon-dev-tfstate"
    prefix = "root/dns"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.40, < 5.0"
    }
  }
}

# Default provider
provider "google" {
  project = var.project
  region  = "europe-west9"
}
