output "vnet" {
  value = {
    id   = azurerm_virtual_network.vnet-spoke.id
    name = azurerm_virtual_network.vnet-spoke.name
    rg   = azurerm_virtual_network.vnet-spoke.resource_group_name
  }
}
