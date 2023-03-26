module "public_zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "4.2.1"

  project_id = var.project
  domain     = "${var.domain}."
  name       = "public-${replace(var.domain, ".", "-")}"
  type       = "public"
}
