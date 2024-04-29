# SPDX-License-Identifier: GPL-2.0-only
resource "kubernetes_service_v1" "app" {
  metadata {
    name        = var.app_name
    annotations = {}
    labels = merge({
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/version"    = var.app_version
      "app.kubernetes.io/part-of"    = var.app_name
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/instance"   = var.app_name
    }, var.service_additional_labels)
  }
  spec {
    type = var.service_type
    selector = {
      "app.kubernetes.io/name" = var.app_name
    }
    port {
      protocol    = "TCP"
      port        = 443
      target_port = "https"
    }
  }
}
