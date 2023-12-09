resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-internal"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "westeurope"
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet-container-apps" {
  name                 = "subnet-test"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/27"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
