# SPDX-License-Identifier: GPL-2.0-only
output "app_url" {
  value       = format("https://%s", var.ingress_host_url)
  description = "Website URL"
}

output "update_secret" {
  value       = kubernetes_secret_v1.app_secrets.data.UPDATE_SECRET
  description = "Update secret for forced manual updates"
  sensitive   = true
}