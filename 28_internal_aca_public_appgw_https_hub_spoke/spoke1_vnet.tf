resource "azurerm_virtual_network" "vnet-spoke1" {
  name                = "vnet-spoke1"
  resource_group_name = azurerm_resource_group.rg-spoke1.name
  location            = azurerm_resource_group.rg-spoke1.location
  address_space       = ["10.1.0.0/16"]
  dns_servers         = [azurerm_firewall.firewall.ip_configuration.0.private_ip_address] # null
}

resource "azurerm_subnet" "snet-spoke1-appgw" {
  name                 = "subnet-spoke1-appgw"
  resource_group_name  = azurerm_virtual_network.vnet-spoke1.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke1.name
  address_prefixes     = ["10.1.0.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Network/applicationGateways"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "snet-spoke1-pe" {
  name                 = "snet-spoke1-pe"
  resource_group_name  = azurerm_virtual_network.vnet-spoke1.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke1.name
  address_prefixes     = ["10.1.2.0/24"]
}
