resource "azurerm_container_app_environment_certificate" "cert" {
  name                         = var.custom_domain_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  # certificate_blob_base64      = azurerm_key_vault_certificate.cert-self-signed.certificate_data_base64
  # certificate_password    = ""
  # certificate_blob_base64 = filebase64("./cert/${var.custom_domain_name}.pfx")
  certificate_blob_base64 = filebase64("./cert/${var.custom_domain_name}.pem")
  certificate_password    = "@Aa123456789"
}

# resource "azurerm_container_app_environment_certificate" "cert" {
#   name                         = var.custom_domain_name
#   container_app_environment_id = azurerm_container_app_environment.env.id
#   certificate_blob_base64      = acme_certificate.certificate.certificate_p12
#   certificate_password         = acme_certificate.certificate.certificate_p12_password
# }
