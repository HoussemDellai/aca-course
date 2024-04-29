module "spoke-aca-1" {
  source        = "./modules/spoke-aca"
  prefix        = "${var.prefix}-1"
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
  prefix        = "${var.prefix}-2"
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

module "spoke-aca" {
  for_each = {
    for idx in range(3, 4): idx => idx
  }
  
  source        = "./modules/spoke-aca"
  prefix        = "${var.prefix}-${each.key}"
  location      = azurerm_resource_group.rg-hub.location
  cidr_vnet     = ["10.${each.key}.0.0/16"]
  cidr_snet_aca = ["10.${each.key}.0.0/24"]
  cidr_snet_vm  = ["10.${each.key}.1.0/24"]

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
