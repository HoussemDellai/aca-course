resource "azurerm_virtual_network_peering" "vnet-peering-hub-to-spoke2" {
  name                         = "vnet-peering-hub-to-spoke2"
  virtual_network_name         = azurerm_virtual_network.vnet-hub.name
  resource_group_name          = azurerm_virtual_network.vnet-hub.resource_group_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "vnet-peering-spoke2-to-hub" {
  name                         = "vnet-peering-spoke2-to-hub"
  virtual_network_name         = azurerm_virtual_network.vnet-spoke2.name
  resource_group_name          = azurerm_virtual_network.vnet-spoke2.resource_group_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}