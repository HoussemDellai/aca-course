resource "azurerm_virtual_network" "vnet-spoke2" {
  name                = "vnet-spoke2"
  resource_group_name = azurerm_resource_group.rg-spoke2.name
  location            = azurerm_resource_group.rg-spoke2.location
  address_space       = ["10.2.0.0/16"]
  # dns_servers         = [azurerm_firewall.firewall.ip_configuration.0.private_ip_address] # null
}

resource "azurerm_subnet" "snet-spoke2-aca" {
  name                 = "subnet-spoke2-workload"
  resource_group_name  = azurerm_virtual_network.vnet-spoke2.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke2.name
  address_prefixes     = ["10.2.0.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}