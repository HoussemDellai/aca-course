resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-dns-${var.prefix}"
  location = var.location
}