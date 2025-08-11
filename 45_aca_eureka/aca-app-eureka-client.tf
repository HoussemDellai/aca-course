resource "azurerm_container_app" "aca_app_eureka_client" {
  name                         = "aca-app-eureka-client"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "aca-app"
      image  = "mcr.microsoft.com/javacomponents/samples/sample-service-eureka-client:latest"
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

output "app_java_eureka_client_fqdn" {
  value = azurerm_container_app.aca_app_eureka_client.latest_revision_fqdn
}