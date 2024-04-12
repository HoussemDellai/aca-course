resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-analytics"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}