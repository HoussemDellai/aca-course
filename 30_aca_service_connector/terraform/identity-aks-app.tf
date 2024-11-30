resource "azurerm_user_assigned_identity" "identity-aca-app" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "identity-aca-app"
}

resource "azurerm_role_assignment" "acr-pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity-aca-app.principal_id
}
