resource "azurerm_network_security_group" "nsg_aca" {
  name                = "nsg-aca"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_all_inbound" {
  network_security_group_name = azurerm_network_security_group.nsg_aca.name
  resource_group_name         = azurerm_network_security_group.nsg_aca.resource_group_name
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

resource "azurerm_network_security_rule" "allow_outbound_service_bus" {
  network_security_group_name = azurerm_network_security_group.nsg_aca.name
  resource_group_name         = azurerm_network_security_group.nsg_aca.resource_group_name
  name                        = "allow-outbound-service-bus"
  access                      = "Allow"
  priority                    = 100
  direction                   = "Outbound"
  protocol                    = "Tcp"
  source_address_prefix       = azurerm_subnet.snet_aca.address_prefixes[0]
  source_port_range           = "*"
  destination_address_prefix  = "ServiceBus.SwedenCentral" # or use Service Bus public IP :"51.12.29.128"
  destination_port_range      = "443"
}

resource "azurerm_subnet_network_security_group_association" "association_nsg_snet_aca" {
  subnet_id                 = azurerm_subnet.snet_aca.id
  network_security_group_id = azurerm_network_security_group.nsg_aca.id
}
