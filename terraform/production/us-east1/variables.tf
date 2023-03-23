variable "project" {
  description = "The ID of the GCP project where the resource will be set"
  type        = string
}

locals {
  region = "us-east1"
  zones  = ["us-east1-b", "us-east1-c", "us-east1-d"]

  cluster = {
    name = "foobar-${local.region}"
  }
}

# It seems there is no zone `-a` in GCP us-east1
# See https://cloud.google.com/compute/docs/regions-zones?hl=fr
