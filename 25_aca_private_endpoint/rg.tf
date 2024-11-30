resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-env-private-endpoint-${var.prefix}"
  location = var.location
}