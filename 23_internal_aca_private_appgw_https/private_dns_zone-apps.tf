resource "azurerm_private_dns_zone" "private-dns-zone-apps" {
  name                = var.custom_domain_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "a-record-app" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.private-dns-zone-apps.name
  resource_group_name = azurerm_private_dns_zone.private-dns-zone-apps.resource_group_name
  ttl                 = 300
  records             = [local.appgw_private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-dns-apps-vnet" {
  name                  = "link-dns-apps-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone-apps.name
  resource_group_name   = azurerm_private_dns_zone.private-dns-zone-apps.resource_group_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
