resource "azurerm_virtual_network" "vnet-hub" {
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.rg-hub.name
  location            = azurerm_resource_group.rg-hub.location
  address_space       = ["172.16.0.0/12"] # until 172.31.255.255
}

resource "azurerm_subnet" "snet-firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg-hub.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_subnet" "snet-bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  resource_group_name  = azurerm_virtual_network.vnet-hub.resource_group_name
  address_prefixes     = ["172.16.1.0/27"]
}