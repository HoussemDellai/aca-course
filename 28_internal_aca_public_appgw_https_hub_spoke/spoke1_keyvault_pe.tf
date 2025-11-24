resource "azurerm_private_endpoint" "pe-keyvault" {
  name                          = "pe-keyvault"
  resource_group_name           = azurerm_resource_group.rg-spoke1.name
  location                      = azurerm_resource_group.rg-spoke1.location
  subnet_id                     = azurerm_subnet.snet-spoke1-pe.id
  custom_network_interface_name = "nic-pe-keyvault"

  private_service_connection {
    name                           = "connection-keyvault"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-keyvault"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone_keyvault.id]
  }
}

resource "azurerm_private_dns_zone" "private_dns_zone_keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg-spoke1.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns-keyvault" {
  name                  = "dns-keyvault"
  resource_group_name   = azurerm_private_dns_zone.private_dns_zone_keyvault.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_keyvault.name
  virtual_network_id    = azurerm_virtual_network.vnet-spoke1.id
}
