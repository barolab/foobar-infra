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

## Lint all source code
lint:
	@docker run --rm \
		--env-file ".github/super-linter.env" \
		-e RUN_LOCAL=true \
		-e USE_FIND_ALGORITHM=false \
		-v "${PWD}":/tmp/lint \
		github/super-linter:slim-v4

## Init the terraform modules
tf-init: tf-init-eu tf-init-us

## Init the terraform GKE module (EU)
tf-init-eu:
	@terraform -chdir=terraform/production/eu-west9/ init

## Init the terraform GKE module (US)
tf-init-us:
	@terraform -chdir=terraform/production/us-east1/ init

## Init the terraform DNS module
tf-init-dns:
	@terraform -chdir=terraform/production/dns/ init

## Apply the terraform modules
tf-apply: tf-apply-eu tf-apply-us

## Apply the terraform module (EU)
tf-apply-eu:
	@terraform -chdir=terraform/production/eu-west9/ apply

## Apply the terraform module (US)
tf-apply-us:
	@terraform -chdir=terraform/production/us-east1/ apply

## Destroy the terraform modules
tf-destroy: tf-destroy-eu tf-destroy-us

## Destroy the terraform module (EU)
tf-destroy-eu:
	@terraform -chdir=terraform/production/eu-west9/ destroy

## Destroy the terraform module (US)
tf-destroy-us:
	@terraform -chdir=terraform/production/us-east1/ destroy

## Destroy the GKE clusters
tf-teardown: tf-teardown-eu tf-teardown-us

## Destroy the GKE cluster (EU)
tf-teardown-eu:
	@terraform -chdir=terraform/production/eu-west9/ destroy -target=module.gke

## Destroy the GKE cluster (US)
tf-teardown-us:
	@terraform -chdir=terraform/production/us-east1/ destroy -target=module.gke

## Get the Kubernetes contexts and put them in ~/.kube/foobar-eu  (EU)
kube-init-eu:
	export KUBECONFIG=~/.kube/foobar-eu
	@gcloud container clusters get-credentials foobar-europe-west9 --region=europe-west9 --project $(project)

## Get the Kubernetes contexts and put them in ~/.kube/foobar-us (US)
kube-init-us:
	export KUBECONFIG=~/.kube/foobar-us
	@gcloud container clusters get-credentials foobar-us-east1 --region=us-east1 --project $(project)

## Get the client certificate from the foobar namespace
get-client-cert:
	@kubectl get configmap raimon-ca -o jsonpath='{.data.ca\.crt}' > "${PWD}/certs/ca.crt"
	@kubectl -n foobar get secret foobar-api-client -o jsonpath='{.data.tls\.crt}' | base64 --decode > "${PWD}/certs/client.crt"
	@kubectl -n foobar get secret foobar-api-client -o jsonpath='{.data.tls\.key}' | base64 --decode > "${PWD}/certs/client.key"

## Send an HTTP request to foobar using mtls
get-mtls:
	@curl \
		--cacert "${PWD}/certs/ca.crt" \
		--cert "${PWD}/certs/client.crt" \
		--key "${PWD}/certs/client.key" \
		-v https://api.raimon.dev/mtls

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
