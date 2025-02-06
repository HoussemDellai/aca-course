resource "azurerm_container_app_custom_domain" "custom-domain" {
  name                                     = var.custom_domain_name
  container_app_id                         = azurerm_container_app.inspactor-gadget.id
  container_app_environment_certificate_id = azapi_resource.certificate.id
  certificate_binding_type                 = "SniEnabled"

  depends_on = [
    azurerm_dns_a_record.dns_a_record_aca_app,
    azurerm_dns_txt_record.dns_txt_record
  ]
}
