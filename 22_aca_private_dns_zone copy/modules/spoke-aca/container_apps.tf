resource "azurerm_container_app_environment" "env" {
  name                           = "aca-environment"
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  log_analytics_workspace_id     = null
  zone_redundancy_enabled        = false
  internal_load_balancer_enabled = true
  infrastructure_subnet_id       = azurerm_subnet.snet-aca.id

  workload_profile {
    name                  = "profile-D4"
    workload_profile_type = "D4" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 1
    maximum_count         = 3
  }
}

resource "azurerm_container_app" "nginx" {
  name                         = "nginx"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "profile-D4"

  template {
    min_replicas = 1
    max_replicas = 3
    container {
      name   = "nginx"
      image  = "nginx:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true # false
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

resource "azurerm_container_app" "inspector-gadget" {
  name                         = "inspector-gadget"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "profile-D4" # "Consumption"

  template {
    min_replicas = 1
    max_replicas = 3
    container {
      name   = "inspector-gadget"
      image  = "jelledruyts/inspectorgadget"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
