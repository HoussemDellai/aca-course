resource "azurerm_network_security_group" "nsg-appgateway" {
  name                = "nsg-appgateway"
  location            = azurerm_resource_group.rg-spoke1.location
  resource_group_name = azurerm_resource_group.rg-spoke1.name
}

resource "azurerm_network_security_rule" "allow-all-inbound" {
  network_security_group_name = azurerm_network_security_group.nsg-appgateway.name
  resource_group_name         = azurerm_network_security_group.nsg-appgateway.resource_group_name
  name                        = "allow-all-inbound"
  access                      = "Allow"
  priority                    = 100
  direction                   = "Inbound"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}

resource "azurerm_network_security_rule" "allow-all-outbound" {
    network_security_group_name = azurerm_network_security_group.nsg-appgateway.name
    resource_group_name         = azurerm_network_security_group.nsg-appgateway.resource_group_name
    name                        = "allow-all-outbound"
    access                      = "Allow"
    priority                    = 100
    direction                   = "Outbound"
    protocol                    = "*"
    source_address_prefix       = "*"
    source_port_range           = "*"
    destination_address_prefix  = "*"
    destination_port_range      = "*"
    }

resource "azurerm_subnet_network_security_group_association" "association-nsg-snet-appgw" {
  subnet_id                 = azurerm_subnet.snet-spoke1-appgw.id
  network_security_group_id = azurerm_network_security_group.nsg-appgateway.id
}
