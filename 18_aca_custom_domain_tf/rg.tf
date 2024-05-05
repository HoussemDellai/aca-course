resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-custom-domain-${var.prefix}"
  location = "swedencentral"
}