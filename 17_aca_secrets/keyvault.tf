resource "azurerm_key_vault" "keyvault" {
  name                       = "kvaca12357911"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
  purge_protection_enabled   = false
}

resource "azurerm_key_vault_secret" "secret_02" {
  name         = "my-secret-02"
  value        = "P@ssw0rd123!"
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on = [ azurerm_role_assignment.role_keyvault_me ]
}

resource "azurerm_role_assignment" "role_keyvault_identity" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}

resource "azurerm_role_assignment" "role_keyvault_me" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_client_config" "current" {}