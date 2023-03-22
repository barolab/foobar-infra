# Terraform

This documentation aims to provide more details about how terraform is used in this repository.
The IaC is mostly meant to manage GCP resources, I suggest you look at [the GCP documentation](./gcp.md)
if you want more details on authentication, project, management, etc...

## State management

Terraform state will be stored on GCS.
The only state that is *not* on the bucket, is the one for `./terraform/root/storage` (because it's used to create the state bucket)
So if you're planning on running the code from this repo, run this module first `./terraform/root/storage` and keep it's tfstate file somewhere safe !

The bucket has versioning enabled in case you want to revert to a previous state.
And the Terraform GCS backend supports locking by default !
That should prevent concurrent execution of Terraform modules
