resource "azurerm_resource_group" "rg" {
  name     = "rg-spoke-aca-${var.prefix}"
  location = var.location
}