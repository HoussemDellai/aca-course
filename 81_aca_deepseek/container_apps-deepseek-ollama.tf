resource "azurerm_container_app" "deepseek-r1" {
  name                         = "deepseek-r1"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "profile-E32" # "Consumption"

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name    = "deepseek"
      image   = "ghcr.io/open-webui/open-webui:ollama"
      cpu     = 30
      memory  = "250Gi"
      # command = ["/bin/sh"]
      # args    = ["-c", "ollama run deepseek-r1:8b"]
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
