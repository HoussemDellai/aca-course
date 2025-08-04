resource "azurerm_container_app_environment" "aca_environment" {
  name                       = "aca-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  logs_destination           = "log-analytics" # azure-monitor
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
}
