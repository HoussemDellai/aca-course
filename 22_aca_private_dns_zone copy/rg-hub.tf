resource "azurerm_resource_group" "rg-hub" {
  name     = "rg-hub-aca-${var.prefix}"
  location = var.location
}