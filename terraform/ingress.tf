# SPDX-License-Identifier: GPL-2.0-only
### Traefik Ingress
resource "kubernetes_manifest" "app_ingress_route_tcp" {
  count = var.use_ingress && var.ingress_controller == "traefik" ? 1 : 0
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name        = var.app_name
      namespace   = data.kubernetes_namespace_v1.app.metadata[0].name
      annotations = var.ingress_annotations
      labels = merge({
        "app.kubernetes.io/component"  = "server"
        "app.kubernetes.io/name"       = var.app_name
        "app.kubernetes.io/version"    = var.app_version
        "app.kubernetes.io/part-of"    = var.app_name
        "app.kubernetes.io/managed-by" = "opentofu"
        "app.kubernetes.io/instance"   = var.app_name
      }, var.ingress_additional_labels)
    }
    spec = {
      entryPoints = var.traefik_entrypoints
      routes = [
        {
          match = format("HostSNI(`%s`)", var.ingress_host_url)
          kind  = "Rule"
          services = [
            {
              name = var.app_name
              port = var.service_container_port
            }
          ]
        }
      ]
      tls = {
        passthrough = true
      }
    }
  }
}
