# SPDX-License-Identifier: GPL-2.0-only
data "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace
  }
}