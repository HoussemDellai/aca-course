resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-dns-appgw-${var.prefix}"
  location = var.location
}