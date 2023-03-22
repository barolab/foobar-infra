variable "project" {
  description = "The ID of the GCP project where the resource will be set"
  type        = string
}

locals {
  region  = "europe-west9"
  zones   = ["europe-west9-a", "europe-west9-b", "europe-west9-c"]

  cluster = {
    name = "foobar-${local.region}"
  }
}
