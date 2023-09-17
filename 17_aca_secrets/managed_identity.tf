resource "azurerm_user_assigned_identity" "identity_aca" {
  name                       = "identity-aca"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
}