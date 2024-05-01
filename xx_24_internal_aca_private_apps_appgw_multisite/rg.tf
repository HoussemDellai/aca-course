resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-appgw-dns-${var.prefix}"
  location = var.location
}