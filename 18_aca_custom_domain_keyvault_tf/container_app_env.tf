resource "azurerm_container_app_environment" "env" {
  name                       = "aca-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = null
}

resource "azapi_update_resource" "aca-env-identity" {
  type        = "Microsoft.App/managedEnvironments@2024-10-02-preview"
  resource_id = azurerm_container_app_environment.env.id

  body = {
    "identity" = {
      "type" = "SystemAssigned"
    }
  }

  response_export_values = ["identity.principalId"]
}

resource "azurerm_role_assignment" "aca-env-identity" {
  principal_id         = azapi_update_resource.aca-env-identity.output.identity.principalId
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.keyvault.id
}
