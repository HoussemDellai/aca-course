resource "azurerm_dns_zone" "dns_zone" {
  name                = var.custom_domain_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "dns_a_record_aca_app" {
  name                = "@"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}

resource "azurerm_dns_txt_record" "dns_txt_record" {
  name                = "asuid"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  record {
    value = azurerm_container_app.inspactor-gadget.custom_domain_verification_id
  }
}
