resource "azurerm_route_table" "route_table" {
  name                = "route-table"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_route" "route_to_firewall" {
  name                   = "route-to-firewall"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = "0.0.0.0/0"        # "10.0.0.0/8" # "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance" # "VirtualNetworkGateway"
  next_hop_in_ip_address = "10.0.2.4" # data.terraform_remote_state.hub.outputs.firewall.private_ip
}

resource "azurerm_subnet_route_table_association" "association_rt_subnet_aca" {
  subnet_id      = azurerm_subnet.snet-aca.id
  route_table_id = azurerm_route_table.route_table.id
}
