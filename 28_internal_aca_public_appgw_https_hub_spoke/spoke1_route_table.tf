resource "azurerm_route_table" "route-table-to-nva-spoke1" {
  name                          = "route-table-to-nva-spoke1"
  location                      = azurerm_resource_group.rg-spoke1.location
  resource_group_name           = azurerm_resource_group.rg-spoke1.name
  bgp_route_propagation_enabled = false
}

# In the current offering of Application Gateway, association of a route table with a rule (or creation of rule) defined as 0.0.0.0/0 with a next hop as virtual appliance is unsupported to ensure proper management of Application Gateway.
# After registration of the feature, the ability to forward traffic to a virtual appliance is now possible via definition of a route table rule that defines 0.0.0.0/0 with a next hop to Virtual Appliance.
# https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment?tabs=cli#route-table-control

# resource "azurerm_route" "route-to-internet-spoke1" {
#   name                   = "route-to-internet-spoke1"
#   resource_group_name    = azurerm_resource_group.rg-spoke1.name
#   route_table_name       = azurerm_route_table.route-table-to-nva-spoke1.name
#   address_prefix         = "0.0.0.0/0" # https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment?tabs=cli#route-table-control
#   next_hop_type          = "VirtualAppliance" # "Internet"
#   next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration.0.private_ip_address
# }

resource "azurerm_route" "route-to-nva-spoke1" {
  name                   = "route-to-nva-spoke1"
  resource_group_name    = azurerm_resource_group.rg-spoke1.name
  route_table_name       = azurerm_route_table.route-table-to-nva-spoke1.name
  address_prefix         = "0.0.0.0/0" # azurerm_subnet.snet-spoke2-aca.address_prefixes[0] # 
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration.0.private_ip_address
}

resource "azurerm_subnet_route_table_association" "association_route_table_snet_spoke1_appgw" {
  subnet_id      = azurerm_subnet.snet-spoke1-appgw.id
  route_table_id = azurerm_route_table.route-table-to-nva-spoke1.id
}
