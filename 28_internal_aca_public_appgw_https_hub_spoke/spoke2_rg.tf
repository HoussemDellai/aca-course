resource "azurerm_resource_group" "rg-spoke2" {
  name     = "rg-spoke2-${var.prefix}"
  location = "swedencentral"
}