resource "azurerm_container_app_environment_certificate" "cert" {
  name                         = var.domain_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  certificate_blob_base64      = acme_certificate.certificate.certificate_p12
  certificate_password         = acme_certificate.certificate.certificate_p12_password
}