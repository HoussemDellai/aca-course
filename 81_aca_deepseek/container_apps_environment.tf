resource "azurerm_container_app_environment" "env" {
  name                       = "aca-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = null
  # zone_redundancy_enabled        = true
  # internal_load_balancer_enabled = true
  # infrastructure_subnet_id       = azurerm_subnet.snet-aca.id

  workload_profile {
    name                  = "profile-E32"
    workload_profile_type = "E32" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 0
    maximum_count         = 1
  }

  workload_profile {
    name                  = "profile-E16"
    workload_profile_type = "E16" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 0
    maximum_count         = 1
  }
}
