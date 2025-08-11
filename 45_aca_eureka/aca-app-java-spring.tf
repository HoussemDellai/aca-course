resource "azurerm_container_app" "aca_app_java_spring" {
  name                         = "aca-app-java-spring"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "aca-app"
      image  = "ghcr.io/azure-samples/javaaccelerator/spring-petclinic-api-gateway"
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

output "app_java_spring_fqdn" {
  value = azurerm_container_app.aca_app_java_spring.latest_revision_fqdn
}