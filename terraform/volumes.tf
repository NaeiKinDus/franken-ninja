# SPDX-License-Identifier: GPL-2.0-only
resource "kubernetes_persistent_volume_claim_v1" "app_data" {
  metadata {
    name        = var.app_name
    annotations = var.persistent_volume_claim_annotations
    labels = merge({
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/version"    = var.app_version
      "app.kubernetes.io/part-of"    = var.app_name
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/instance"   = var.app_name
    }, var.persistent_volume_claim_labels)
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.persistent_volume_claim_storage_class
    resources {
      requests = {
        storage = var.persistent_volume_claim_storage_capacity
      }
      limits = {
        storage = var.persistent_volume_storage_claim_capacity_limit
      }
    }
  }
  wait_until_bound = false
}
