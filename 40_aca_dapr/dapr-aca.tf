resource "azurerm_container_app_environment_dapr_component" "dapr_component" {
  name                         = "statestore"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  component_type               = "state.azure.blobstorage"
  version                      = "v1"
  scopes                       = [azurerm_container_app.aca_nodeapp.name]
  init_timeout                 = "5s"
  ignore_errors                = false

  metadata {
    name  = "accountName"
    value = azurerm_storage_account.storage.name
  }

  metadata {
    name  = "containerName"
    value = azurerm_storage_container.container.name
  }

  metadata {
    name  = "azureClientId"
    value = azurerm_user_assigned_identity.identity_aca_nodeapp.client_id
  }
}

# # statestore.yaml for Azure Blob storage component
# componentType: state.azure.blobstorage
# version: v1
# metadata:
#   - name: accountName
#     value: "<STORAGE_ACCOUNT_NAME>"
#   - name: containerName
#     value: mycontainer
#   - name: azureClientId
#     value: "<MANAGED_IDENTITY_CLIENT_ID>"
# scopes:
#   - nodeapp
