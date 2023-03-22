resource "google_storage_bucket" "tfstate" {
  name          = "foobar-raimon-dev-tfstate"
  location      = "EU"
  force_destroy = true

  public_access_prevention = "enforced"
  versioning {
    enabled = true
  }
}