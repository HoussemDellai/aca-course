resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-workload-profile"
  location = "northeurope"
}

resource "azurerm_container_app_environment" "env" {
  name                = "aca-environment"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  workload_profile {
    name                  = "profile-D8"
    workload_profile_type = "D8" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 0
    maximum_count         = 10
  }

  workload_profile {
    name                  = "profile-E4"
    workload_profile_type = "E4" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 1
    maximum_count         = 3
  }
}

resource "azurerm_container_app" "app" {
  name                         = "aca-app-demo"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "profile-D8"

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
