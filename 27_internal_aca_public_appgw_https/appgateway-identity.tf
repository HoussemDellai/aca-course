resource "azurerm_user_assigned_identity" "identity-appgw" {
  name                = "identity-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "identity-appgw-secret-user" {
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.identity-appgw.principal_id
  scope                = azurerm_key_vault.keyvault.id
}