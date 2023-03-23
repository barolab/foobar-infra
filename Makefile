# COLORS
TARGET_MAX_CHAR_NUM := 15
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
PWD    := $(shell pwd)

# Variables
project=$(or ${GCP_PROJECT},${GCP_PROJECT},test)

.PHONY: all hooks vim ash asdf docker packages dotfiles help
default: help

## Format the Terraform code
fmt:
	@terraform fmt -write -recursive ./terraform

## Initialize the terraform modules
tf-init:
	@terraform -chdir=terraform/production/eu-west9/ init
	@terraform -chdir=terraform/production/us-east1/ init

## Apply the terraform modules
tf-apply:
	@terraform -chdir=terraform/production/eu-west9/ apply
	@terraform -chdir=terraform/production/us-east1/ apply

## Destroy the terraform modules
tf-destroy:
	@terraform -chdir=terraform/production/eu-west9/ apply
	@terraform -chdir=terraform/production/us-east1/ apply

## Destroy Flux resources and the GKE clusters
tf-teardown:
	export KUBECONFIG=~/.kube/foobar-eu
	@kubectl -n flux-system delete gitrepository --all
	@kubectl -n flux-system delete kustomization --all
	@terraform -chdir=terraform/production/eu-west9/ destroy -target=module.gke
	export KUBECONFIG=~/.kube/foobar-us
	@kubectl -n flux-system delete gitrepository --all
	@kubectl -n flux-system delete kustomization --all
	@terraform -chdir=terraform/production/us-east1/ destroy -target=module.gke

## Get the Kubernetes contexts and put them in ~/.kube/foobar
kube-init:
	export KUBECONFIG=~/.kube/foobar-eu
	@gcloud container clusters get-credentials foobar-europe-west9 --region=europe-west9 --project $(project)
	export KUBECONFIG=~/.kube/foobar-us
	@gcloud container clusters get-credentials foobar-us-east1 --region=us-east1 --project $(project)

## Print this help message
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
