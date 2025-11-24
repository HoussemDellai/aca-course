resource "azurerm_route_table" "route-table-to-nva-spoke1" {
  name                          = "route-table-to-nva-spoke1"
  location                      = azurerm_resource_group.rg-spoke1.location
  resource_group_name           = azurerm_resource_group.rg-spoke1.name
  bgp_route_propagation_enabled = false
}

resource "azurerm_route" "route-to-nva-spoke1" {
  name                   = "route-to-nva-spoke1"
  resource_group_name    = azurerm_resource_group.rg-spoke1.name
  route_table_name       = azurerm_route_table.route-table-to-nva-spoke1.name
  address_prefix         = "0.0.0.0/0" # azurerm_virtual_network.vnet-spoke2.address_space[0] # "10.2.0.0/16" # 
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration.0.private_ip_address # module.vm-hub-nva.vm_private_ip
}

resource "azurerm_subnet_route_table_association" "association_route_table_snet_spoke1_appgw" {
  subnet_id      = azurerm_subnet.snet-spoke1-appgw.id
  route_table_id = azurerm_route_table.route-table-to-nva-spoke1.id
}
