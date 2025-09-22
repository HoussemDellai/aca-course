resource "azurerm_container_app_environment" "aca_environment" {
  name                           = "aca-environment"
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  logs_destination               = "log-analytics" # azure-monitor
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.la.id

  workload_profile {
    name                  = "profile-D4"
    workload_profile_type = "D4" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 1
    maximum_count         = 3
  }
}
