resource "azurerm_virtual_network" "vnet-spoke" {
  name                = "vnet-spoke"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.cidr_vnet
}

resource "azurerm_subnet" "snet-aca" {
  name                 = "snet-aca"
  virtual_network_name = azurerm_virtual_network.vnet-spoke.name
  resource_group_name  = azurerm_virtual_network.vnet-spoke.resource_group_name
  address_prefixes     = var.cidr_snet_aca

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "snet-vm" {
  name                 = "snet-vm"
  virtual_network_name = azurerm_virtual_network.vnet-spoke.name
  resource_group_name  = azurerm_virtual_network.vnet-spoke.resource_group_name
  address_prefixes     = var.cidr_snet_vm
}
