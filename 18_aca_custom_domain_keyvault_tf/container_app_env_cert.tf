resource "azapi_resource" "certificate" {
  type      = "Microsoft.App/managedEnvironments/certificates@2024-10-02-preview"
  parent_id = azurerm_container_app_environment.env.id
  name      = var.custom_domain_name
  location  = azurerm_container_app_environment.env.location

  body = {
    properties = {
      certificateType = "ServerSSLCertificate"
      certificateKeyVaultProperties = {
        identity    = "system"
        keyVaultUrl = azurerm_key_vault_certificate.cert-self-signed.versionless_secret_id
      }
    }
  }
}

# The following is not working. Seems an issue with terraform provider.
# resource "azurerm_container_app_environment_certificate" "cert" {
#   name                         = var.custom_domain_name
#   container_app_environment_id = azurerm_container_app_environment.env.id
#   # certificate_blob_base64      = filebase64("./cert/${var.custom_domain_name}.pfx")
#   # certificate_password         = "@Aa123456789"
#   certificate_blob_base64 = azurerm_key_vault_certificate.cert-self-signed.certificate_data_base64
#   certificate_password    = ""
# }
