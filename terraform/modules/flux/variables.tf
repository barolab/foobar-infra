variable "name" {
  description = "The name of the Flux deploy keys in Github"
  default     = "flux"
  type        = string
}

variable "namespace" {
  description = "In which namespace Flux will be deployed"
  default     = "flux-system"
  type        = string
}

variable "known_hosts" {
  description = "SSH known_hosts file with the Github key"
  default     = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  type        = string
}

variable "chart" {
  description = "Configure the Helm Chart used to deploy Flux v2"
  type = object({
    repository = optional(string, "https://fluxcd-community.github.io/helm-charts")
    version    = optional(string, "2.7.0")
    name       = optional(string, "flux2")
  })
}

variable "repositories" {
  description = "The Git repositories to sync with Flux"
  type = map(object({
    git = object({
      url      = string
      branch   = optional(string, "main")
      interval = optional(string, "2m")
      timeout  = optional(string, "2m")
    })

    kustomizations = map(object({
      path     = string
      interval = optional(string, "2m")
      timeout  = optional(string, "2m")
      prune    = optional(bool, true)
      wait     = optional(bool, true)
    }))
  }))
}

variable "controllers" {
  description = "Set of configuration for the Flux controllers"
  type = object({
    source = object({
      create = optional(bool, true)
      resources = optional(object({
        requests = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "100m")
        }), {})
        limits = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "")
        }), {})
      }), {})
    })

    kustomize = object({
      create = optional(bool, true)
      resources = optional(object({
        requests = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "100m")
        }), {})
        limits = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "")
        }), {})
      }), {})
    })

    helm = object({
      create = optional(bool, true)
      resources = optional(object({
        requests = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "100m")
        }), {})
        limits = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "")
        }), {})
      }), {})
    })
  })
}
