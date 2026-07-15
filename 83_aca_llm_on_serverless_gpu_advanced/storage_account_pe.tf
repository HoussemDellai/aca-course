resource "azurerm_private_dns_zone" "dns_zone_storage_account" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_storage_account" {
  name                  = "dns-zone-link-storage-account"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_storage_account.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "pe_storage_account" {
  name                          = "pe-storage-account"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = azurerm_subnet.snet_pe.id
  custom_network_interface_name = "nic-pe-storage-account"

  private_dns_zone_group {
    name                 = "group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone_storage_account.id]
  }

  private_service_connection {
    name                           = "connection"
    private_connection_resource_id = azurerm_storage_account.storage_llm.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}
