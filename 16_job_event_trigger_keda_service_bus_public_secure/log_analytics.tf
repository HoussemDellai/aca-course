resource "azurerm_log_analytics_workspace" "la" {
  name                = "log-analytics-aca"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}