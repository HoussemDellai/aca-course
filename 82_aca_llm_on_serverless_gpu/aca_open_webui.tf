resource "azurerm_container_app" "open_webui" {
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  name                         = "open-webui"
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  ingress {
    allow_insecure_connections = true
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas                     = 1
    max_replicas                     = 1
    polling_interval_in_seconds      = 30
    cooldown_period_in_seconds       = 300
    termination_grace_period_seconds = 30

    container {
      image  = "ghcr.io/open-webui/open-webui:main"
      name   = "open-webui"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "OPENAI_API_BASE_URL"
        value = "http://${azurerm_container_app.aca_gemma4_31b_it_a100.ingress.0.fqdn}/v1"
      }
    }
  }
}

output "aca_open_webui_fqdn" {
  value = azurerm_container_app.open_webui.ingress.0.fqdn
}
