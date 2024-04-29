resource "kubernetes_config_map_v1" "app_config" {
  metadata {
    name        = var.app_name
    annotations = var.configmap_app_annotations
    labels = merge({
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/version"    = var.app_version
      "app.kubernetes.io/part-of"    = var.app_name
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/instance"   = var.app_name
    }, var.configmap_app_additional_labels)
  }
  data = {
    APP_URL                       = format("https://%s", var.ingress_host_url)
    SERVER_NAME                   = var.ingress_host_url
    DB_CONNECTION                 = var.app_config_db_connection
    DB_HOST                       = var.app_config_db_host
    DB_DATABASE                   = var.app_config_db_database_name
    DB_PORT                       = var.app_config_db_database_port
    DB_USERNAME                   = var.app_config_db_username
    REDIS_HOST                    = var.app_config_redis_host
    REDIS_PORT                    = var.app_config_redis_port
    MAIL_MAILER                   = var.app_config_mailer
    MAIL_ENCRYPTION               = var.app_config_mailer_encryption
    MAIL_FROM_ADDRESS             = var.app_config_mailer_from_addr
    MAIL_FROM_NAME                = var.app_config_mailer_from_name
    MAIL_HOST                     = var.app_config_mailer_host
    MAIL_LOG_CHANNEL              = var.app_config_mailer_log_channel
    MAIL_USERNAME                 = var.app_config_mailer_username
    MAIL_PORT                     = var.app_config_mailer_port
    QUEUE_CONNECTION              = var.app_config_queue_connection_backend
    QUEUE_WORKERS_BACKOFF_PERIOD  = var.app_config_queue_workers_backoff_period
    QUEUE_WORKERS_MAX_TRIES       = var.app_config_queue_workers_max_tries
    QUEUE_WORKERS_MEMORY_MAX      = var.app_config_queue_workers_memory_max
    QUEUE_WORKERS_SLEEP_PERIOD    = var.app_config_queue_workers_sleep_period
    APP_DEBUG                     = var.app_config_enable_debug
    CACHE_DRIVER                  = var.app_config_cache_driver
    DELETE_BACKUP_DAYS            = var.app_config_delete_backup_days
    DELETE_PDF_DAYS               = var.app_config_delete_pdf_days
    ERROR_EMAIL                   = var.app_config_error_email
    LOG_CHANNEL                   = var.app_config_log_channel
    PDF_GENERATOR                 = var.app_config_pdf_generator
    PHANTOMJS_PDF_GENERATION      = "false"
    REQUIRE_HTTPS                 = "true"
    SESSION_DRIVER                = var.app_config_session_driver
    TRUSTED_PROXIES               = var.app_config_trusted_proxies
    CADDY_GLOBAL_OPTIONS          = var.caddy_global_options
    CADDY_SERVER_EXTRA_DIRECTIVES = var.caddy_server_extra_directives
  }
}

resource "kubernetes_secret_v1" "app_secrets" {
  metadata {
    name        = "config-secrets"
    annotations = var.secrets_annotations
    labels = merge({
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/version"    = var.app_version
      "app.kubernetes.io/part-of"    = var.app_name
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/instance"   = var.app_name
    }, var.secrets_additional_labels)
  }
  data = {
    APP_KEY             = var.app_config_app_key
    DB_PASSWORD         = var.app_config_db_password
    REDIS_PASSWORD      = var.app_config_redis_password
    MAIL_PASSWORD       = var.app_config_mailer_password
    OPENEXCHANGE_APP_ID = var.app_config_plugins_openexchange_app_id
    ZIP_TAX_KEY         = var.app_config_plugins_zip_tax_key
    UPDATE_SECRET       = var.app_config_update_secret == "" ? var.app_config_update_secret : random_bytes.update_secret.base64
  }
}

resource "random_bytes" "update_secret" {
  length = 64
}
