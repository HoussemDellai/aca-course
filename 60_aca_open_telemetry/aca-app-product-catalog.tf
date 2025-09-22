resource "azurerm_container_app" "aca_app_productcatalog" {
  name                         = "aca-app-productcatalog"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "aca-app"
      image  = "ghcr.io/open-telemetry/demo:2.0.2-product-catalog"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "app_fqdn_productcatalog" {
  value = azurerm_container_app.aca_app_productcatalog.latest_revision_fqdn
}