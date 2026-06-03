resource "azurerm_public_ip_prefix" "pip_prefix_nat_gateway" {
  name                = "pip-prefix-nat-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  prefix_length       = 30
  sku                 = "StandardV2"
#   zones               = [1, 2, 3] # `StandardV2` are zone-redundant by default, Azure automatically deploys across all available zones. The `zones` argument must be omitted
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "nat-gateway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "StandardV2"
  idle_timeout_in_minutes = 10
#   zones                   = [1, 2, 3] # `StandardV2` are zone-redundant by default, Azure automatically deploys across all available zones. The `zones` argument must be omitted
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "association_pip_prefix_nat_gateway" {
  nat_gateway_id      = azurerm_nat_gateway.nat_gateway.id
  public_ip_prefix_id = azurerm_public_ip_prefix.pip_prefix_nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "snet_natgw" {
  subnet_id      = azurerm_subnet.snet_aca.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

output "pip_prefix_nat_gateway" {
  value = azurerm_public_ip_prefix.pip_prefix_nat_gateway.ip_prefix
}
