resource "azurerm_container_app_environment" "env" {
  name                           = "aca-environment"
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  zone_redundancy_enabled        = true
  internal_load_balancer_enabled = true
  infrastructure_subnet_id       = azurerm_subnet.subnet-container-apps.id
  log_analytics_workspace_id     = null
}

resource "azurerm_container_app" "app" {
  name                         = "aca-app-demo"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "helloworld-app"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}
