resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-private-consumption-${var.prefix}"
  location = var.location
}