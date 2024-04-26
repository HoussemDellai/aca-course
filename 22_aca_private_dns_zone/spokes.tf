module "spoke-aca-1" {
  source        = "./modules/spoke-aca"
  prefix        = "22-1"
  location      = azurerm_resource_group.rg-hub.location
  cidr_vnet     = ["10.1.0.0/16"]
  cidr_snet_aca = ["10.1.0.0/24"]
  cidr_snet_vm  = ["10.1.1.0/24"]

  vnet_hub = {
    name                = azurerm_virtual_network.vnet-hub.name
    resource_group_name = azurerm_virtual_network.vnet-hub.resource_group_name
    id                  = azurerm_virtual_network.vnet-hub.id
  }

  private_dns_zone = {
    name                = azurerm_private_dns_zone.private-dns-zone.name
    resource_group_name = azurerm_private_dns_zone.private-dns-zone.resource_group_name
  }
}

module "spoke-aca-2" {
  source        = "./modules/spoke-aca"
  prefix        = "22-2"
  location      = azurerm_resource_group.rg-hub.location
  cidr_vnet     = ["10.2.0.0/16"]
  cidr_snet_aca = ["10.2.0.0/24"]
  cidr_snet_vm  = ["10.2.1.0/24"]

  vnet_hub = {
    name                = azurerm_virtual_network.vnet-hub.name
    resource_group_name = azurerm_virtual_network.vnet-hub.resource_group_name
    id                  = azurerm_virtual_network.vnet-hub.id
  }

  private_dns_zone = {
    name                = azurerm_private_dns_zone.private-dns-zone.name
    resource_group_name = azurerm_private_dns_zone.private-dns-zone.resource_group_name
  }
}
