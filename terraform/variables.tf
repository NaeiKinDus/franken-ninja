# SPDX-License-Identifier: GPL-2.0-only
variable "kubeconfig_path" {
  default     = "~/.kube/config"
  description = "Path to the kubeconfig file"
  type        = string
  nullable    = false
}

variable "kubeconfig_context" {
  default     = "default"
  description = "Context to use to access the cluster"
  type        = string
  nullable    = false
}

variable "app_version" {
  default     = "unknown"
  description = "Version of Invoice Ninja application"
  type        = string
}

variable "app_name" {
  default     = "invoice-ninja"
  description = "Application name, used by various resources such as deployment, ingress, container, ..."
  type        = string
  nullable    = false
  validation {
    condition     = length(regexall("[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*", var.app_name)) > 0
    error_message = "Invalid value for 'app_name', must respect RFC 1123"
  }
}

### Invoice Ninja configuration
variable "app_backend_replicas" {
  default     = 1
  description = "Number of backend containers; increase if your queue workers are overloaded"
  type        = number
  nullable    = false
  validation {
    condition     = var.app_backend_replicas >= 1
    error_message = "At least one backend container is required"
  }
}

variable "app_config_app_key" {
  description = "APP_KEY; fill in your own that starts with 'base64:' or generate a new one (see documentation)"
  type        = string
  sensitive   = true
  nullable    = false
  validation {
    condition     = startswith(var.app_config_app_key, "base64:")
    error_message = "Malformed / missing app_config_app_key; must start with 'base64:'"
  }
}

variable "app_config_db_connection" {
  default     = "mysql"
  description = "DB_CONNECTION; DB connection type; only 'mysql' is supported unless you alter the source image to add the required dependencies"
  nullable    = false
  type        = string
}

variable "app_config_db_host" {
  description = "DB_HOST; DB host"
  nullable    = false
  type        = string
}

variable "app_config_db_database_port" {
  default     = 3306
  description = "DB_PORT; database connection port"
  type        = number
  nullable    = false
}

variable "app_config_db_database_name" {
  default     = "invoice_ninja"
  description = "DB_DATABASE; database name"
  type        = string
  nullable    = false
}

variable "app_config_db_username" {
  default     = "invoice_ninja"
  description = "DB_USERNAME; database username"
  type        = string
  nullable    = false
}

variable "app_config_db_password" {
  description = "DB_PASSWORD; database user's password"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "app_config_redis_host" {
  description = "REDIS_HOST; Redis host"
  type        = string
  nullable    = false
}

variable "app_config_redis_password" {
  description = "REDIS_PASSWORD; Redis password, if required"
  type        = string
  sensitive   = true
}

variable "app_config_redis_port" {
  default     = 6379
  description = "REDIS_PORT; Redis connection port"
  type        = number
  nullable    = false
}

variable "app_config_mailer" {
  default     = "log"
  description = "MAIL_MAILER; Redis connection port"
  type        = string
  nullable    = false
}

variable "app_config_mailer_encryption" {
  default     = "tls"
  description = "MAIL_ENCRYPTION; Redis connection port"
  type        = string
  nullable    = false
}

variable "app_config_mailer_from_addr" {
  default     = "invoice@localhost"
  description = "MAIL_FROM_ADDRESS; address used to send emails"
  type        = string
  nullable    = false
}

variable "app_config_mailer_from_name" {
  default     = "Invoice Ninja"
  description = "MAIL_FROM_NAME; name shown when sending emails"
  type        = string
  nullable    = false
}

variable "app_config_mailer_host" {
  description = "MAIL_HOST; mailer's host name"
  type        = string
}

variable "app_config_mailer_log_channel" {
  default     = "stderr"
  description = "MAIL_LOG_CHANNEL; log channel to use with mailer-related logs"
  type        = string
}

variable "app_config_mailer_username" {
  description = "MAIL_USERNAME; username of the mailer account used to send emails"
  type        = string
}

variable "app_config_mailer_password" {
  description = "MAIL_PASSWORD; email of the mailer account used"
  type        = string
  sensitive   = true
}

variable "app_config_mailer_port" {
  default     = 587
  description = "MAIL_PORT; mailer service port"
  type        = number
}

variable "app_config_queue_connection_backend" {
  default     = "redis"
  description = "QUEUE_CONNECTION; connection queue backend"
  type        = string
  nullable    = false
}

variable "app_config_queue_workers_backoff_period" {
  default     = 10
  description = "QUEUE_WORKERS_BACKOFF_PERIOD; workers back-off period"
  type        = number
  nullable    = false
}

variable "app_config_queue_workers_max_tries" {
  default     = 3
  description = "QUEUE_WORKERS_MAX_TRIES; number of tries a worker will perform before failing a job"
  type        = number
  nullable    = false
}

variable "app_config_queue_workers_memory_max" {
  default     = 256
  description = "QUEUE_WORKERS_MEMORY_MAX; maximum memory, in MB, a worker can consume"
  type        = number
  nullable    = false
}

variable "app_config_queue_workers_sleep_period" {
  default     = 3
  description = "QUEUE_WORKERS_SLEEP_PERIOD; sleep period between two jobs polling for a worker"
  type        = number
  nullable    = false
}

variable "app_config_plugins_openexchange_app_id" {
  description = "OPENEXCHANGE_APP_ID; OpenExchange 3rd party service provider APP ID"
  type        = string
  sensitive   = true
}

variable "app_config_plugins_zip_tax_key" {
  description = "ZIP_TAX_KEY;ZipTax 3rd party service provider API key "
  type        = string
  sensitive   = true
}

variable "app_config_enable_debug" {
  default     = false
  description = "APP_DEBUG; enable debug mode for application"
  type        = bool
  nullable    = false
}

variable "app_config_cache_driver" {
  default     = "redis"
  description = "CACHE_DRIVER; cache driver to use"
  type        = string
  nullable    = false
}

variable "app_config_delete_backup_days" {
  default     = 90
  description = "DELETE_BACKUP_DAYS; days before a backup is purged"
  type        = number
  nullable    = false
}

variable "app_config_delete_pdf_days" {
  default     = 0
  description = "DELETE_PDF_DAYS; days before a PDF file is purged"
  type        = number
  nullable    = false
}

variable "app_config_error_email" {
  description = "ERROR_EMAIL; mail address error reports will be sent to"
  type        = string
}

variable "app_config_log_channel" {
  default     = "stderr"
  description = "LOG_CHANNEL; channel used to send application errors to"
  type        = string
  nullable    = false
}

variable "app_config_pdf_generator" {
  default     = "snappdf"
  description = "PDF_GENERATOR; PDF generator to use; highly recommended to stick to the default"
  type        = string
  nullable    = false
}

variable "app_config_session_driver" {
  default     = "redis"
  description = "SESSION_DRIVER; session driver backend"
  type        = string
  nullable    = false
}

variable "app_config_trusted_proxies" {
  default     = "*"
  description = "TRUSTED_PROXIES; trusted proxies"
  type        = string
  nullable    = false
}

variable "app_config_update_secret" {
  description = "UPDATE_SECRET; secret used when calling the '/update' endpoint"
  type        = string
  sensitive   = true
}

### Namespace
variable "app_namespace" {
  default     = "default"
  description = "Namespace used to deploy app resources"
  type        = string
}

### Configmap
variable "configmap_app_additional_labels" {
  default     = {}
  description = "Additional app Configmap labels"
  type        = map(any)
}

variable "configmap_app_annotations" {
  default     = {}
  description = "Annotations for the app Configmap resource"
  type        = map(any)
}

### Secrets
variable "secrets_annotations" {
  default     = {}
  description = "Annotations for the Secret resource"
  type        = map(any)
}

variable "secrets_additional_labels" {
  default     = {}
  description = "Additional app Secret labels"
  type        = map(any)
}

### Deployment
variable "deployment_replicas" {
  default     = 1
  description = "Number of instances how the web app"
  type        = number
}

variable "deployment_additional_labels" {
  default     = {}
  description = "Additionnal labels for the deployment resource"
  type        = map(any)
}

variable "deployment_pods_additional_labels" {
  default     = {}
  description = "Additionnal labels for the pods managed by the deployment resource"
  type        = map(any)
}

variable "deployment_annotations" {
  default     = {}
  description = "Annotations for the deployment resource"
  type        = map(any)
}

variable "deployment_pods_annotations" {
  default     = {}
  description = "Annotations for the pods managed by the deployment resource"
  type        = map(any)
}

### Container
variable "container_image" {
  default     = "pouncetech/invoiceninja"
  description = "Image to use for the web app"
  type        = string
  nullable    = false
}

variable "container_image_pull_policy" {
  default     = "IfNotPresent"
  description = "Pull policy; valid values are 'Always', 'IfNotPresent', 'Never'"
  type        = string

  validation {
    condition     = contains(["Always", "IfNotPresent", "Never"], var.container_image_pull_policy)
    error_message = "Invalid value for 'image_pull_policy'"
  }
}

variable "liveness_probe_initial_delay" {
  default     = 60
  description = "Initial delay for liveness probe, in seconds"
  type        = number
}

variable "liveness_probe_failure_threshold" {
  default     = 6
  description = "Consecutive failures before considering the liveness probe failed"
  type        = number
}

variable "readiness_probe_initial_delay" {
  default     = 30
  description = "Initial delay for readiness probe, in seconds"
  type        = number
}

variable "readiness_probe_failure_threshold" {
  default     = 6
  description = "Consecutive failures before considering the readiness probe failed"
  type        = number
}

variable "upkeep_liveness_probe_initial_delay" {
  default     = 60
  description = "Initial delay for liveness probe, in seconds"
  type        = number
}

variable "upkeep_liveness_probe_failure_threshold" {
  default     = 6
  description = "Consecutive failures before considering the liveness probe failed"
  type        = number
}

variable "upkeep_readiness_probe_initial_delay" {
  default     = 30
  description = "Initial delay for readiness probe, in seconds"
  type        = number
}

variable "upkeep_readiness_probe_failure_threshold" {
  default     = 6
  description = "Consecutive failures before considering the readiness probe failed"
  type        = number
}

variable "container_resources_limits" {
  default = {
    cpu    = "500m"
    memory = "256Mi"
  }
  description = "Resources limits for the app container; supports 'cpu', 'memory', 'hugepages-2Mi' and 'hugepages-1Gi'"
  type = object(
    {
      cpu           = optional(string)
      memory        = optional(string)
      hugepages-2Mi = optional(string)
      hugepages-1Gi = optional(string)
    }
  )
}

variable "container_resources_requests" {
  default = {
    cpu    = "1000m"
    memory = "512Mi"
  }
  description = "Resources requests for the app container; supports 'cpu', 'memory', 'hugepages-2Mi' and 'hugepages-1Gi'"
  type = object(
    {
      cpu           = optional(string)
      memory        = optional(string)
      hugepages-2Mi = optional(string)
      hugepages-1Gi = optional(string)
    }
  )
}

variable "upkeep_container_resources_limits" {
  default = {
    cpu    = "500m"
    memory = "256Mi"
  }
  description = "Resources limits for the app container; supports 'cpu', 'memory', 'hugepages-2Mi' and 'hugepages-1Gi'"
  type = object(
    {
      cpu           = optional(string)
      memory        = optional(string)
      hugepages-2Mi = optional(string)
      hugepages-1Gi = optional(string)
    }
  )
}

variable "upkeep_container_resources_requests" {
  default = {
    cpu    = "1000m"
    memory = "512Mi"
  }
  description = "Resources requests for the app container; supports 'cpu', 'memory', 'hugepages-2Mi' and 'hugepages-1Gi'"
  type = object(
    {
      cpu           = optional(string)
      memory        = optional(string)
      hugepages-2Mi = optional(string)
      hugepages-1Gi = optional(string)
    }
  )
}

### Volumes
variable "persistent_volume_claim_annotations" {
  default     = {}
  description = "Annotations for the persistent volume shared between containers"
  type        = map(any)
}

variable "persistent_volume_claim_labels" {
  default     = {}
  description = "Labels for the persistent volume shared between containers"
  type        = map(any)
}

variable "persistent_volume_claim_storage_capacity" {
  default     = "10Gi"
  description = "Persistent Volume requested size"
  type        = string
}

variable "persistent_volume_storage_claim_capacity_limit" {
  default     = "20Gi"
  description = "Maximum Persistent Volume size allowed"
  type        = string
}

variable "persistent_volume_claim_storage_class" {
  default     = "local-path"
  description = "Persistent Volume Claim storage class; depends on your kubernetes cluster provider"
  type        = string
}

### Ingress
variable "use_ingress" {
  default     = true
  description = "Whether to use an ingress or not"
  type        = bool
}

variable "ingress_controller" {
  default     = "traefik"
  description = "Type of ingress controller used; only traefik is supported at the moment"
  type        = string
  nullable    = false
  validation {
    condition     = contains(["traefik"], var.ingress_controller)
    error_message = "Invalid value for 'ingress_controller'"
  }
}

variable "ingress_annotations" {
  default     = {}
  description = "Ingress resource annotations"
  type        = map(any)
}

variable "ingress_additional_labels" {
  default     = {}
  description = "Ingress resource annotations"
  type        = map(any)
}

variable "ingress_class" {
  default     = "traefik"
  description = "Class name of the ingress controller"
  type        = string
}

variable "ingress_host_url" {
  description = "Host used for the app, without the protocol prefix"
  type        = string
  nullable    = false
}

### Service
variable "service_container_port" {
  default     = 443
  description = "HTTP port used by the container"
  type        = number
  nullable    = false
}

variable "service_annotations" {
  default     = {}
  description = "Annotations for the service resource"
  type        = map(any)
}

variable "service_additional_labels" {
  default     = {}
  description = "Additional labels for the service resource"
  type        = map(any)
}

variable "service_type" {
  default     = "ClusterIP"
  description = "Type of the service resource"
  type        = string
}

### Service Account
variable "service_account_name" {
  default     = "invoice-ninja"
  description = "Service account used for web app"
  type        = string
  nullable    = false
  validation {
    condition     = length(regexall("[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*", var.service_account_name)) > 0
    error_message = "Invalid value for 'service_account_name', must respect RFC 1123"
  }
}

variable "service_account_additional_annotations" {
  default     = {}
  description = "Additional annotations for the app's service account"
  type        = map(any)
}

variable "service_account_labels" {
  default     = {}
  description = "Labels for the service account used by the app"
  type        = map(any)
}

### Traefik
variable "traefik_entrypoints" {
  default     = ["websecure"]
  description = "List of entrypoints used for the IngressTCP Traefik CRD"
  type        = list(string)
  nullable    = false
}

### Caddy
variable "caddy_global_options" {
  description = "Global options to pass to Caddy (e.g. 'debug')"
  type        = string
}

variable "caddy_server_extra_directives" {
  default     = "tls internal"
  description = "Extra server directives, e.g. TLS configuration options"
  type        = string
}
