resource "azurerm_container_app" "aca_backend" {
  name                         = "aca-app-backend-api"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "backend-api"
      image  = "ghcr.io/houssemdellai/containerapps-album-backend:v1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = false # true
    target_port                = 3500
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}