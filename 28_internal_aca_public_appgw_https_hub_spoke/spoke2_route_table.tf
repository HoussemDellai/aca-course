resource "azurerm_route_table" "route-table-to-nva-spoke2" {
  name                          = "route-table-to-nva-spoke2"
  location                      = azurerm_resource_group.rg-spoke2.location
  resource_group_name           = azurerm_resource_group.rg-spoke2.name
  bgp_route_propagation_enabled = false
}

resource "azurerm_route" "route-to-nva-spoke2" {  
  name                   = "route-to-nva-spoke2"
  resource_group_name    = azurerm_resource_group.rg-spoke2.name
  route_table_name       = azurerm_route_table.route-table-to-nva-spoke2.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration.0.private_ip_address
}

resource "azurerm_subnet_route_table_association" "association_route_table_subnet_spoke2" {
  subnet_id      = azurerm_subnet.snet-spoke2-aca.id
  route_table_id = azurerm_route_table.route-table-to-nva-spoke2.id
}
