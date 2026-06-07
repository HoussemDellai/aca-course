
resource "azurerm_container_app_environment_storage" "storage_aca_llm_nfs" {
  name                         = "storage-aca-llm-nfs"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  share_name                   = "/${azurerm_storage_account.storage_llm.name}/${azurerm_storage_share.fileshare_llm.name}" # azurerm_storage_share.fileshare_llm.name
  nfs_server_url               = "${azurerm_storage_account.storage_llm.name}.file.core.windows.net"
  access_mode                  = "ReadWrite" # "ReadOnly"
}

# resource "azurerm_container_app_environment_storage" "storage_aca_llm_smb" {
#   name                         = "storage-aca-llm-smb"
#   container_app_environment_id = azurerm_container_app_environment.aca_environment.id
#   account_name                 = azurerm_storage_account.storage_llm.name
#   share_name                   = azurerm_storage_share.fileshare_llm.name
#   access_key                   = azurerm_storage_account.storage_llm.primary_access_key
#   access_mode                  = "ReadWrite" # "ReadOnly"
# }

# role assignment to allow ACA environment to access the storage account File Share
resource "azurerm_role_assignment" "aca_env_storage_blob_data_contributor" {
  scope                = azurerm_storage_share.fileshare_llm.id # azurerm_storage_account.storage_llm.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_container_app_environment.aca_environment.identity.0.principal_id
}
