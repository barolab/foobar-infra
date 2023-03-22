terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }
}

provider "google" {}
