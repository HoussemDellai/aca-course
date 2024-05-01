resource "azurerm_private_dns_zone" "private-dns-zone-aca" {
  name                = azurerm_container_app_environment.env.default_domain
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "a-record-aca" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.private-dns-zone-aca.name
  resource_group_name = azurerm_private_dns_zone.private-dns-zone-aca.resource_group_name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}

resource "azurerm_private_dns_a_record" "a-record-wild-card" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.private-dns-zone-aca.name
  resource_group_name = azurerm_private_dns_zone.private-dns-zone-aca.resource_group_name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-dns-aca-vnet" {
  name                  = "link-dns-aca-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone-aca.name
  resource_group_name   = azurerm_private_dns_zone.private-dns-zone-aca.resource_group_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}