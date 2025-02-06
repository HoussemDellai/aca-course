resource "azurerm_container_app" "inspactor-gadget" {
  name                         = "inspactor-gadget"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_container_app_environment.env.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "app"
      image  = "jelledruyts/inspectorgadget"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    transport                  = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}