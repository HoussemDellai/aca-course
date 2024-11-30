resource "azurerm_private_dns_zone" "private-dns-zone-aca-environment" {
  name                = "privatelink.${var.location}.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "a-record" {
  name                = split(".", azurerm_container_app_environment.env.default_domain)[0]
  zone_name           = azurerm_private_dns_zone.private-dns-zone-aca-environment.name
  resource_group_name = azurerm_private_dns_zone.private-dns-zone-aca-environment.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe.private_service_connection.0.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-dns-vnet" {
  name                  = "link-dns-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone-aca-environment.name
  resource_group_name   = azurerm_private_dns_zone.private-dns-zone-aca-environment.resource_group_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}