
# peering between hub and spoke1
resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                         = "hub-to-spoke-${var.prefix}"
  virtual_network_name         = var.vnet_hub.name
  resource_group_name          = var.vnet_hub.resource_group_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# peering between spoke1 and hub
resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                         = "spoke-${var.prefix}-to-hub"
  virtual_network_name         = azurerm_virtual_network.vnet-spoke.name
  resource_group_name          = azurerm_virtual_network.vnet-spoke.resource_group_name
  remote_virtual_network_id    = var.vnet_hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}