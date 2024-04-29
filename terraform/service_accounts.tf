# SPDX-License-Identifier: GPL-2.0-only
resource "kubernetes_service_account_v1" "invoice" {
  metadata {
    name = var.service_account_name
    annotations = merge({
      "kubernetes.io/enforce-mountable-secrets" = true
    }, var.service_account_additional_annotations)
    labels = merge({
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/version"    = var.app_version
      "app.kubernetes.io/part-of"    = var.app_name
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/instance"   = var.app_name
    }, var.service_account_labels)
  }
  secret {
    name = kubernetes_secret_v1.app_secrets.metadata[0].name
  }
}