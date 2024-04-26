resource "azurerm_resource_group" "rg-hub" {
  name     = "rg-aca-hub-${var.prefix}"
  location = "swedencentral"
}