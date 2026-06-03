resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-private-endpoint-${var.prefix}"
  location = var.location
}