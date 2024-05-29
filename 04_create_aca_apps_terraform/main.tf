resource "azurerm_resource_group" "rg" {
  name     = "rg-containerapps-terraform-04"
  location = "swedencentral"
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "workspace-aca"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_environment" {
  name                       = "aca-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
}

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

resource "azurerm_container_app" "aca_frontend" {
  name                         = "aca-app-frontend-ui"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend-ui"
      image  = "ghcr.io/houssemdellai/containerapps-album-frontend:v1"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "API_BASE_URL"
        value = "https://${azurerm_container_app.aca_backend.latest_revision_fqdn}"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "app_frontend_url" {
  value = azurerm_container_app.aca_frontend.latest_revision_fqdn
}