resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aca"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet_aca" {
  name                            = "snet-aca"
  resource_group_name             = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  address_prefixes                = ["10.0.1.0/26"]
  default_outbound_access_enabled = true

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "snet_pe" {
  name                            = "snet-pe"
  resource_group_name             = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  address_prefixes                = ["10.0.2.0/27"]
  default_outbound_access_enabled = true
}
