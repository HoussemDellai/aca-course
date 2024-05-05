# resource "azurerm_container_app_custom_domain" "custom-domain" {
#   name                                     = trimprefix(azurerm_dns_txt_record.dns_txt_record.fqdn, "asuid.")
#   container_app_id                         = azurerm_container_app.aca.id
#   container_app_environment_certificate_id = azurerm_container_app_environment_certificate.cert.id
#   certificate_binding_type                 = "SniEnabled"
# }