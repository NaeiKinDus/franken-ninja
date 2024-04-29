terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
  required_version = ">= 1.6.2"
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = data.kubernetes_namespace_v1.app.metadata[0].name
    labels = merge({
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/version"    = var.app_version
      "app.kubernetes.io/part-of"    = var.app_name
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/instance"   = var.app_name
    }, var.deployment_additional_labels)
    annotations = var.deployment_annotations
  }
  spec {
    replicas = var.deployment_replicas
    strategy {
      rolling_update {
        max_unavailable = 1
      }
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.app_name
      }
    }
    template {
      metadata {
        annotations = var.deployment_pods_annotations
        labels = merge({
          "app.kubernetes.io/component"  = "server"
          "app.kubernetes.io/name"       = var.app_name
          "app.kubernetes.io/version"    = var.app_version
          "app.kubernetes.io/part-of"    = var.app_name
          "app.kubernetes.io/managed-by" = "opentofu"
          "app.kubernetes.io/instance"   = var.app_name
        }, var.deployment_pods_additional_labels)
      }
      spec {
        service_account_name = var.service_account_name
        security_context {
          run_as_non_root = true
          run_as_group    = 1000
          run_as_user     = 1000
        }
        init_container {
          name              = format("%s-init", var.app_name)
          image             = var.container_image
          image_pull_policy = var.container_image_pull_policy
          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            capabilities {
              drop = ["ALL"]
            }
          }
          env_from {
            secret_ref {
              name     = kubernetes_secret_v1.app_secrets.metadata[0].name
              optional = false
            }
          }
          env_from {
            config_map_ref {
              name     = kubernetes_config_map_v1.app_config.metadata[0].name
              optional = false
            }
          }
          env {
            name  = "APP_TYPE"
            value = "init"
          }
          volume_mount {
            mount_path        = "/app_mount"
            name              = kubernetes_persistent_volume_claim_v1.app_data.metadata[0].name
            mount_propagation = "HostToContainer"
          }

        }
        ## Web service
        container {
          name              = var.app_name
          image             = var.container_image
          image_pull_policy = var.container_image_pull_policy
          port {
            name           = "https"
            container_port = 443
          }
          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }
          readiness_probe {
            initial_delay_seconds = var.readiness_probe_initial_delay
            failure_threshold     = var.readiness_probe_failure_threshold
            period_seconds        = 5
            success_threshold     = 1
            timeout_seconds       = 10
            exec {
              command = ["curl", "-f", "http://localhost:2019/metrics"]
            }
          }
          liveness_probe {
            initial_delay_seconds = var.liveness_probe_initial_delay
            failure_threshold     = var.liveness_probe_failure_threshold
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            exec {
              command = ["curl", "-kf", format("https://%s", var.ingress_host_url)]
            }
          }
          env_from {
            secret_ref {
              name     = kubernetes_secret_v1.app_secrets.metadata[0].name
              optional = false
            }
          }
          env_from {
            config_map_ref {
              name     = kubernetes_config_map_v1.app_config.metadata[0].name
              optional = false
            }
          }
          env {
            name  = "APP_TYPE"
            value = "app"
          }
          resources {
            limits   = var.container_resources_limits
            requests = var.container_resources_requests
          }
          volume_mount {
            mount_path        = "/app"
            name              = kubernetes_persistent_volume_claim_v1.app_data.metadata[0].name
            mount_propagation = "HostToContainer"
          }
        }
        ## Backend upkeep containers
        dynamic "container" {
          for_each = range(0, var.app_backend_replicas)
          iterator = replica_index
          content {
            name              = format("%s-backend-replica-%s", var.app_name, replica_index.value)
            image             = var.container_image
            image_pull_policy = var.container_image_pull_policy
            security_context {
              allow_privilege_escalation = false
              privileged                 = false
              capabilities {
                drop = ["ALL"]
                add  = ["NET_BIND_SERVICE"]
              }
            }
            readiness_probe {
              initial_delay_seconds = var.upkeep_readiness_probe_initial_delay
              failure_threshold     = var.upkeep_readiness_probe_failure_threshold
              period_seconds        = 5
              success_threshold     = 1
              timeout_seconds       = 10
              exec {
                command = ["pgrep", "-f", "php /app/artisan schedule:work"]
              }
            }
            liveness_probe {
              initial_delay_seconds = var.upkeep_liveness_probe_initial_delay
              failure_threshold     = var.upkeep_liveness_probe_failure_threshold
              period_seconds        = 10
              success_threshold     = 1
              timeout_seconds       = 10
              exec {
                command = ["pgrep", "-f", "php /app/artisan schedule:work"]
              }
            }
            env_from {
              secret_ref {
                name     = kubernetes_secret_v1.app_secrets.metadata[0].name
                optional = false
              }
            }
            env_from {
              config_map_ref {
                name     = kubernetes_config_map_v1.app_config.metadata[0].name
                optional = false
              }
            }
            env {
              name  = "APP_TYPE"
              value = "upkeep"
            }
            resources {
              limits   = var.upkeep_container_resources_limits
              requests = var.upkeep_container_resources_requests
            }
            volume_mount {
              mount_path        = "/app"
              name              = kubernetes_persistent_volume_claim_v1.app_data.metadata[0].name
              mount_propagation = "HostToContainer"
            }
          }
        }
        volume {
          name = kubernetes_persistent_volume_claim_v1.app_data.metadata[0].name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.app_data.metadata[0].name
          }
        }
      }
    }
  }
}
