resource "azurerm_user_assigned_identity" "identity_aca_nodeapp" {
  name                = "identity-aca-nodeapp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "role_storage_aca" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.identity_aca_nodeapp.principal_id
}