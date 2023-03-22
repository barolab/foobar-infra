project=$(or ${GCP_PROJECT},${GCP_PROJECT},test)

fmt:
	@terraform fmt -write -recursive ./terraform

tf-init:
	@terraform -chdir=terraform/production/eu-west9/ init
	@terraform -chdir=terraform/production/us-east1/ init

tf-apply:
	@terraform -chdir=terraform/production/eu-west9/ apply
	@terraform -chdir=terraform/production/us-east1/ apply

tf-destroy:
	@terraform -chdir=terraform/production/eu-west9/ apply
	@terraform -chdir=terraform/production/us-east1/ apply

tf-teardown:
	@terraform -chdir=terraform/production/eu-west9/ destroy -target=module.gke
	@terraform -chdir=terraform/production/us-east1/ destroy -target=module.gke

kube-init:
	export KUBECONFIG=~/.kube/foobar
	@gcloud container clusters get-credentials foobar-europe-west9 --region=europe-west9 --project $(project)
	@gcloud container clusters get-credentials foobar-us-east1 --region=us-east1 --project $(project)
