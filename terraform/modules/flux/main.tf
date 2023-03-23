# Create an SSH keypair for Flux to authenticate on the repository
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Add the Key as a GitHub deploy key on the repository
resource "github_repository_deploy_key" "flux" {
  for_each   = var.repositories
  title      = var.name
  repository = each.key
  key        = sensitive(chomp(tls_private_key.flux.public_key_openssh))
  read_only  = "false"
}

# Create the namespace where flux will be deployed
resource "kubernetes_namespace" "flux" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

# Generate the K8S secret containing the key
resource "kubernetes_secret" "flux" {
  depends_on = [tls_private_key.flux]

  metadata {
    name      = "flux-ssh"
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    "identity"     = sensitive(tls_private_key.flux.private_key_openssh)
    "identity.pub" = sensitive(chomp(tls_private_key.flux.public_key_openssh))
    "known_hosts"  = sensitive(var.known_hosts)
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations
    ]
  }
}

# Deploy Flux controllers using the community Helm Chart
resource "helm_release" "flux" {
  depends_on = [kubernetes_secret.flux]

  name       = "flux"
  namespace  = var.namespace
  repository = var.chart.repository
  version    = var.chart.version
  chart      = var.chart.name

  values = [
    templatefile("${path.module}/templates/values.tftpl", {
      source_controller_create          = var.controllers.source.create
      source_controller_cpu_requests    = var.controllers.source.resources.requests.cpu
      source_controller_cpu_limits      = var.controllers.source.resources.limits.cpu
      source_controller_memory_requests = var.controllers.source.resources.requests.memory
      source_controller_memory_limits   = var.controllers.source.resources.limits.memory

      kustomize_controller_create          = var.controllers.kustomize.create
      kustomize_controller_cpu_requests    = var.controllers.kustomize.resources.requests.cpu
      kustomize_controller_cpu_limits      = var.controllers.kustomize.resources.limits.cpu
      kustomize_controller_memory_requests = var.controllers.kustomize.resources.requests.memory
      kustomize_controller_memory_limits   = var.controllers.kustomize.resources.limits.memory

      helm_controller_create          = var.controllers.helm.create
      helm_controller_cpu_requests    = var.controllers.helm.resources.requests.cpu
      helm_controller_cpu_limits      = var.controllers.helm.resources.limits.cpu
      helm_controller_memory_requests = var.controllers.helm.resources.requests.memory
      helm_controller_memory_limits   = var.controllers.helm.resources.limits.memory
    })
  ]
}

# Create the Flux GitRepository resources
resource "kubectl_manifest" "git_repo" {
  depends_on = [helm_release.flux]
  for_each   = var.repositories

  yaml_body = templatefile(
    "${path.module}/templates/git-repo.tftpl",
    {
      name      = each.key
      namespace = var.namespace

      url      = each.value.git.url
      branch   = each.value.git.branch
      timeout  = each.value.git.timeout
      interval = each.value.git.interval
      secret   = "flux-ssh"
    }
  )
}

locals {
  # flatten ensures that this local value is a flat list of objects, rather than a list of lists of objects
  kustomizations = flatten([
    for repo_name, repo in var.repositories : [
      for ks_name, ks in repo.kustomizations : {
        name       = ks_name
        path       = ks.path
        wait       = ks.wait
        prune      = ks.prune
        timeout    = ks.timeout
        interval   = ks.interval
        repository = repo_name
      }
    ]
  ])
}

# Create the Flux Kustomization resources
resource "kubectl_manifest" "flux_kustomizations" {
  depends_on = [helm_release.flux]

  # local.kustomizations is a list, so we must now project it into a map where each key is unique. We'll combine the git_repository and kustomizations keys to produce a single unique key per instance.
  for_each = {
    for ks in local.kustomizations : "${ks.repository}-${ks.name}" => ks
  }

  yaml_body = templatefile(
    "${path.module}/templates/kustomization.tftpl",
    {
      name      = "${each.value.repository}-${each.value.name}"
      namespace = var.namespace

      path       = each.value.path
      wait       = each.value.wait
      prune      = each.value.prune
      timeout    = each.value.timeout
      interval   = each.value.interval
      repository = each.value.repository
    }
  )
}
