# SPDX-License-Identifier: GPL-2.0-only
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
  experiments {
    manifest_resource = true
  }
}
